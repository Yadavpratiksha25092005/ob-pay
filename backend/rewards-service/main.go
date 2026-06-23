package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

var db *sql.DB

// Reward rule definitions — points awarded per event type.
// One-time events are enforced via the reward_events idempotency table.
const (
	RuleSignupBonus       = "signup_bonus"       // 100 pts — once per user
	RuleFirstTransaction  = "first_transaction"   // 500 pts — once per user
	RuleReferral          = "referral_bonus"       // 200 pts — once per referrer per referee
	RuleTransactionBonus  = "transaction_bonus"    // 10 pts per ₹100 — every transaction
)

var rewardPoints = map[string]int{
	RuleSignupBonus:      100,
	RuleFirstTransaction: 500,
	RuleReferral:         200,
}

func corsOrigins() []string {
	if v := os.Getenv("ALLOWED_ORIGINS"); v != "" {
		var out []string
		for _, o := range strings.Split(v, ",") {
			if s := strings.TrimSpace(o); s != "" {
				out = append(out, s)
			}
		}
		return out
	}
	if os.Getenv("APP_ENV") == "production" {
		return []string{"https://obpay.in", "https://admin.obpay.in"}
	}
	return []string{"http://localhost:3000", "http://localhost:8080", "http://localhost:8081"}
}

func main() {
	var err error
	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		dbPassword := os.Getenv("DB_PASSWORD")
		if dbPassword == "" {
			dbPassword = "pratiksha123"
		}
		connStr = "host=localhost port=5432 user=postgres password=" + dbPassword + " dbname=obpay_db sslmode=disable"
	}
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("DB connection failed:", err)
	}
	defer db.Close()

	if err = db.Ping(); err != nil {
		log.Fatal("DB ping failed:", err)
	}

	createTables()

	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins:     corsOrigins(),
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Request-ID"},
		AllowCredentials: true,
	}))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "rewards"})
	})

	r.GET("/api/v1/rewards/:user_id", getRewards)
	r.POST("/api/v1/rewards/event", triggerRewardEvent) // reward engine entry point
	r.POST("/api/v1/rewards/add", addPoints)            // manual/admin credit
	r.POST("/api/v1/rewards/redeem", redeemPoints)
	r.GET("/api/v1/offers", getOffers)

	log.Println("Rewards Service running on :8012")
	r.Run(":8012")
}

func createTables() {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS user_rewards (
			id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id     UUID NOT NULL UNIQUE,
			points      INTEGER NOT NULL DEFAULT 0,
			total_earned    INTEGER NOT NULL DEFAULT 0,
			total_redeemed  INTEGER NOT NULL DEFAULT 0,
			created_at  TIMESTAMP DEFAULT NOW(),
			updated_at  TIMESTAMP DEFAULT NOW()
		)`,
		// idempotency table — prevents duplicate one-time bonuses
		`CREATE TABLE IF NOT EXISTS reward_events (
			id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id     UUID NOT NULL,
			event_type  VARCHAR(50) NOT NULL,
			ref_id      VARCHAR(100),
			points      INTEGER NOT NULL DEFAULT 0,
			created_at  TIMESTAMP DEFAULT NOW(),
			UNIQUE (user_id, event_type, ref_id)
		)`,
		`CREATE TABLE IF NOT EXISTS reward_transactions (
			id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id     UUID NOT NULL,
			points      INTEGER NOT NULL,
			type        VARCHAR(20) NOT NULL,
			description TEXT,
			created_at  TIMESTAMP DEFAULT NOW()
		)`,
		`CREATE TABLE IF NOT EXISTS offers (
			id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			title          VARCHAR(100) NOT NULL,
			subtitle       TEXT,
			code           VARCHAR(50),
			category       VARCHAR(50),
			discount_type  VARCHAR(20),
			discount_value FLOAT,
			min_amount     FLOAT DEFAULT 0,
			valid_till     TIMESTAMP,
			is_active      BOOLEAN DEFAULT TRUE,
			created_at     TIMESTAMP DEFAULT NOW()
		)`,
	}

	for _, q := range queries {
		if _, err := db.Exec(q); err != nil {
			log.Println("Table creation error:", err)
		}
	}

	insertDefaultOffers()
}

func insertDefaultOffers() {
	var count int
	db.QueryRow("SELECT COUNT(*) FROM offers").Scan(&count)
	if count > 0 {
		return
	}

	offers := []struct {
		title, subtitle, code, category, discountType string
		discountValue, minAmount                      float64
	}{
		{"Flat ₹75 Cashback", "on Electricity Bill Payment", "SAVE75", "electricity", "flat", 75, 500},
		{"Upto ₹100 Cashback", "on Mobile Recharge", "RECHARGE100", "recharge", "flat", 100, 199},
		{"Get 10% Cashback", "on DTH Recharge", "DTH10", "dth", "percent", 10, 149},
		{"Flat ₹50 Cashback", "on Bill Payments", "BILL50", "bills", "flat", 50, 200},
		{"Free Transfer", "Send money up to ₹1,000", "FREE1K", "transfer", "flat", 0, 0},
		{"₹25 Cashback", "on First UPI Payment", "FIRST25", "upi", "flat", 25, 100},
	}

	for _, o := range offers {
		db.Exec(`INSERT INTO offers (title,subtitle,code,category,discount_type,discount_value,min_amount,valid_till)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
			o.title, o.subtitle, o.code, o.category, o.discountType, o.discountValue, o.minAmount,
			time.Now().AddDate(0, 3, 0))
	}
}

// creditPoints adds points to the user's balance in a single DB transaction.
// It does NOT check for idempotency — callers must guard via reward_events.
func creditPoints(userID string, pts int, description string) error {
	tx, err := db.Begin()
	if err != nil {
		return err
	}
	_, err = tx.Exec(`
		INSERT INTO user_rewards (user_id, points, total_earned)
		VALUES ($1, $2, $2)
		ON CONFLICT (user_id) DO UPDATE
		SET points       = user_rewards.points + $2,
		    total_earned = user_rewards.total_earned + $2,
		    updated_at   = NOW()
	`, userID, pts)
	if err != nil {
		tx.Rollback()
		return err
	}
	_, err = tx.Exec(`
		INSERT INTO reward_transactions (user_id, points, type, description)
		VALUES ($1, $2, 'earned', $3)
	`, userID, pts, description)
	if err != nil {
		tx.Rollback()
		return err
	}
	return tx.Commit()
}

// GET /api/v1/rewards/:user_id
func getRewards(c *gin.Context) {
	userID := c.Param("user_id")

	var points, totalEarned, totalRedeemed int
	err := db.QueryRow(
		`SELECT points, total_earned, total_redeemed FROM user_rewards WHERE user_id=$1`,
		userID,
	).Scan(&points, &totalEarned, &totalRedeemed)

	if err == sql.ErrNoRows {
		// New user — initialise with 0 points (no auto-credit)
		db.Exec(`INSERT INTO user_rewards (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`, userID)
		points, totalEarned, totalRedeemed = 0, 0, 0
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rewards"})
		return
	}

	rows, _ := db.Query(
		`SELECT points, type, description, created_at
		 FROM reward_transactions WHERE user_id=$1 ORDER BY created_at DESC LIMIT 20`,
		userID,
	)
	var transactions []map[string]interface{}
	if rows != nil {
		defer rows.Close()
		for rows.Next() {
			var pts int
			var txType, desc string
			var createdAt time.Time
			rows.Scan(&pts, &txType, &desc, &createdAt)
			transactions = append(transactions, map[string]interface{}{
				"points":      pts,
				"type":        txType,
				"description": desc,
				"created_at":  createdAt,
			})
		}
	}
	if transactions == nil {
		transactions = []map[string]interface{}{}
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":        userID,
		"points":         points,
		"total_earned":   totalEarned,
		"total_redeemed": totalRedeemed,
		"cash_value":     float64(points) / 100.0,
		"transactions":   transactions,
	})
}

// POST /api/v1/rewards/event — primary reward engine entry point.
// Request: { user_id, event_type, ref_id?, transaction_amount? }
// Supported event_type values: signup_bonus, first_transaction,
//   referral_bonus, transaction_bonus
func triggerRewardEvent(c *gin.Context) {
	var req struct {
		UserID            string  `json:"user_id"`
		EventType         string  `json:"event_type"`
		RefID             string  `json:"ref_id"`              // idempotency key (e.g. payment ID)
		TransactionAmount float64 `json:"transaction_amount"` // for transaction_bonus
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.UserID == "" || req.EventType == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id and event_type are required"})
		return
	}

	// ref_id defaults to event_type for one-time events (enforces uniqueness)
	refID := req.RefID
	if refID == "" {
		refID = req.EventType
	}

	var pts int

	switch req.EventType {
	case RuleSignupBonus, RuleFirstTransaction, RuleReferral:
		// One-time events: insert into reward_events with UNIQUE constraint
		pts = rewardPoints[req.EventType]
		_, err := db.Exec(`
			INSERT INTO reward_events (user_id, event_type, ref_id, points)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (user_id, event_type, ref_id) DO NOTHING
		`, req.UserID, req.EventType, refID, pts)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record event"})
			return
		}
		// Check if insert was a no-op (duplicate)
		var eventExists bool
		db.QueryRow(`SELECT EXISTS(SELECT 1 FROM reward_events WHERE user_id=$1 AND event_type=$2 AND ref_id=$3)`,
			req.UserID, req.EventType, refID).Scan(&eventExists)
		if !eventExists {
			// truly no-op — shouldn't happen but guard it
			c.JSON(http.StatusOK, gin.H{"message": "Reward already credited", "points": 0, "duplicate": true})
			return
		}
		// Check if this was a fresh insert (points not credited yet)
		// We rely on the fact that if ON CONFLICT fired, no credit was issued
		var rowCount int
		db.QueryRow(`SELECT COUNT(*) FROM reward_events WHERE user_id=$1 AND event_type=$2 AND ref_id=$3 AND points=$4`,
			req.UserID, req.EventType, refID, pts).Scan(&rowCount)
		if rowCount == 0 {
			c.JSON(http.StatusOK, gin.H{"message": "Reward already credited", "points": 0, "duplicate": true})
			return
		}

	case RuleTransactionBonus:
		// Per-transaction: 10 points per ₹100, minimum ₹1
		if req.TransactionAmount <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "transaction_amount required for transaction_bonus"})
			return
		}
		pts = int(req.TransactionAmount/100) * 10
		if pts < 1 {
			pts = 1
		}
		// Guard duplicates per payment using ref_id (payment_id)
		if refID != "" && refID != req.EventType {
			res, err := db.Exec(`
				INSERT INTO reward_events (user_id, event_type, ref_id, points)
				VALUES ($1, $2, $3, $4)
				ON CONFLICT (user_id, event_type, ref_id) DO NOTHING
			`, req.UserID, req.EventType, refID, pts)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record event"})
				return
			}
			n, _ := res.RowsAffected()
			if n == 0 {
				c.JSON(http.StatusOK, gin.H{"message": "Reward already credited for this transaction", "points": 0, "duplicate": true})
				return
			}
		}

	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Unknown event_type: " + req.EventType})
		return
	}

	if pts <= 0 {
		c.JSON(http.StatusOK, gin.H{"message": "No points earned", "points": 0})
		return
	}

	description := eventDescription(req.EventType, req.TransactionAmount)
	if err := creditPoints(req.UserID, pts, description); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to credit points"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Points credited",
		"points":     pts,
		"event_type": req.EventType,
	})
}

func eventDescription(eventType string, amount float64) string {
	switch eventType {
	case RuleSignupBonus:
		return "Welcome bonus for joining OB Pay"
	case RuleFirstTransaction:
		return "Bonus for completing your first transaction"
	case RuleReferral:
		return "Referral bonus"
	case RuleTransactionBonus:
		return "Points earned on payment"
	}
	return eventType
}

// POST /api/v1/rewards/add — manual / admin point credit (no duplicate check)
func addPoints(c *gin.Context) {
	var req struct {
		UserID      string `json:"user_id"`
		Points      int    `json:"points"`
		Description string `json:"description"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.Points <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Points must be greater than 0"})
		return
	}
	if err := creditPoints(req.UserID, req.Points, req.Description); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add points"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Points added", "points": req.Points})
}

// POST /api/v1/rewards/redeem
func redeemPoints(c *gin.Context) {
	var req struct {
		UserID string `json:"user_id"`
		Points int    `json:"points"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.Points <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Points must be greater than 0"})
		return
	}

	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Transaction failed"})
		return
	}

	var currentPoints int
	err = tx.QueryRow(`SELECT points FROM user_rewards WHERE user_id=$1 FOR UPDATE`, req.UserID).Scan(&currentPoints)
	if err != nil || currentPoints < req.Points {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient points"})
		return
	}

	_, err = tx.Exec(`
		UPDATE user_rewards
		SET points=points-$1, total_redeemed=total_redeemed+$1, updated_at=NOW()
		WHERE user_id=$2
	`, req.Points, req.UserID)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Redemption failed"})
		return
	}

	_, err = tx.Exec(`
		INSERT INTO reward_transactions (user_id, points, type, description)
		VALUES ($1, $2, 'redeemed', 'Points redeemed for cashback')
	`, req.UserID, req.Points)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Redemption failed"})
		return
	}

	if err = tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Commit failed"})
		return
	}

	cashback := float64(req.Points) / 100.0
	c.JSON(http.StatusOK, gin.H{
		"message":  "Points redeemed successfully",
		"points":   req.Points,
		"cashback": cashback,
	})
}

// GET /api/v1/offers
func getOffers(c *gin.Context) {
	rows, err := db.Query(
		`SELECT id,title,subtitle,code,category,discount_type,discount_value,min_amount,valid_till
		 FROM offers WHERE is_active=TRUE ORDER BY created_at DESC`,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch offers"})
		return
	}
	defer rows.Close()

	var offers []map[string]interface{}
	for rows.Next() {
		var id, title, subtitle, code, category, discountType string
		var discountValue, minAmount float64
		var validTill time.Time
		rows.Scan(&id, &title, &subtitle, &code, &category, &discountType, &discountValue, &minAmount, &validTill)
		offers = append(offers, map[string]interface{}{
			"id":             id,
			"title":          title,
			"subtitle":       subtitle,
			"code":           code,
			"category":       category,
			"discount_type":  discountType,
			"discount_value": discountValue,
			"min_amount":     minAmount,
			"valid_till":     validTill,
		})
	}
	if offers == nil {
		offers = []map[string]interface{}{}
	}

	c.JSON(http.StatusOK, gin.H{"offers": offers, "count": len(offers)})
}
