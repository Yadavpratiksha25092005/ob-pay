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

	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins:     corsOrigins(),
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Request-ID"},
		AllowCredentials: true,
	}))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "analytics"})
	})

	// Per-user analytics (merchant/agent dashboard)
	r.GET("/api/v1/analytics/:user_id", getAnalytics)
	r.GET("/api/v1/analytics/:user_id/summary", getSummary)

	// Platform-wide admin analytics
	r.GET("/api/v1/analytics/admin/overview", getAdminOverview)
port := os.Getenv("PORT")
if port == "" {
    port = "8013"
}
log.Println("Analytics Service running on :" + port)
r.Run(":" + port)
}

// periodStart returns the start time for the requested period.
// Supported values: "week" (7d), "month" (30d), "quarter" (90d), "year" (365d).
func periodStart(period string) time.Time {
	now := time.Now()
	switch period {
	case "week":
		return now.AddDate(0, 0, -7)
	case "quarter":
		return now.AddDate(0, -3, 0)
	case "year":
		return now.AddDate(-1, 0, 0)
	default: // "month"
		return now.AddDate(0, -1, 0)
	}
}

// GET /api/v1/analytics/:user_id?period=week|month|quarter|year
func getAnalytics(c *gin.Context) {
	userID := c.Param("user_id")
	period := c.DefaultQuery("period", "month")
	startDate := periodStart(period)
	now := time.Now()

	// Total revenue received by this user
	var totalRevenue float64
	db.QueryRow(`
		SELECT COALESCE(SUM(amount), 0)
		FROM payments
		WHERE receiver_user_id = $1 AND created_at >= $2 AND status = 'success'
	`, userID, startDate).Scan(&totalRevenue)

	// Total transactions
	var totalTx int
	db.QueryRow(`
		SELECT COUNT(*)
		FROM payments
		WHERE receiver_user_id = $1 AND created_at >= $2 AND status = 'success'
	`, userID, startDate).Scan(&totalTx)

	// Average per day
	days := now.Sub(startDate).Hours() / 24
	avgPerDay := 0.0
	if days > 0 {
		avgPerDay = totalRevenue / days
	}

	// Best day of week by total amount
	var bestDay string
	db.QueryRow(`
		SELECT TO_CHAR(created_at, 'Day')
		FROM payments
		WHERE receiver_user_id = $1 AND created_at >= $2 AND status = 'success'
		GROUP BY TO_CHAR(created_at, 'Day')
		ORDER BY SUM(amount) DESC
		LIMIT 1
	`, userID, startDate).Scan(&bestDay)
	bestDay = strings.TrimSpace(bestDay)
	if bestDay == "" {
		bestDay = "N/A"
	}

	// Daily revenue for chart
	rows, err := db.Query(`
		SELECT DATE(created_at) AS day, COALESCE(SUM(amount), 0)
		FROM payments
		WHERE receiver_user_id = $1 AND created_at >= $2 AND status = 'success'
		GROUP BY day ORDER BY day ASC
	`, userID, startDate)

	var chartData []map[string]interface{}
	if err == nil && rows != nil {
		defer rows.Close()
		for rows.Next() {
			var day time.Time
			var total float64
			rows.Scan(&day, &total)
			chartData = append(chartData, map[string]interface{}{
				"day":    day.Format("2 Jan"),
				"amount": total,
			})
		}
	}
	if chartData == nil {
		chartData = []map[string]interface{}{}
	}

	// Payment method breakdown — real counts from DB
	methodRows, _ := db.Query(`
		SELECT COALESCE(payment_method, 'wallet'), COUNT(*), COALESCE(SUM(amount), 0)
		FROM payments
		WHERE receiver_user_id = $1 AND created_at >= $2 AND status = 'success'
		GROUP BY payment_method
	`, userID, startDate)

	type methodStat struct {
		count  int
		amount float64
	}
	methods := map[string]methodStat{}
	if methodRows != nil {
		defer methodRows.Close()
		for methodRows.Next() {
			var method string
			var cnt int
			var amt float64
			methodRows.Scan(&method, &cnt, &amt)
			methods[method] = methodStat{cnt, amt}
		}
	}

	paymentMethods := gin.H{}
	for method, stat := range methods {
		pct := 0.0
		if totalTx > 0 {
			pct = float64(stat.count) / float64(totalTx) * 100
		}
		paymentMethods[method] = gin.H{
			"count":   stat.count,
			"amount":  stat.amount,
			"percent": pct,
		}
	}

	// Top 5 transactions by amount
	txRows, _ := db.Query(`
		SELECT p.id, p.amount, p.description, p.created_at,
		       COALESCE(u.full_name, 'Customer') AS sender_name
		FROM payments p
		LEFT JOIN users u ON u.id = p.sender_user_id
		WHERE p.receiver_user_id = $1 AND p.created_at >= $2 AND p.status = 'success'
		ORDER BY p.amount DESC
		LIMIT 5
	`, userID, startDate)

	var topTx []map[string]interface{}
	if txRows != nil {
		defer txRows.Close()
		for txRows.Next() {
			var id, desc, name string
			var amount float64
			var createdAt time.Time
			txRows.Scan(&id, &amount, &desc, &createdAt, &name)
			topTx = append(topTx, map[string]interface{}{
				"id":         id,
				"amount":     amount,
				"name":       name,
				"time":       formatTime(createdAt),
				"created_at": createdAt,
			})
		}
	}
	if topTx == nil {
		topTx = []map[string]interface{}{}
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":          userID,
		"period":           period,
		"total_revenue":    totalRevenue,
		"transactions":     totalTx,
		"avg_per_day":      avgPerDay,
		"best_day":         bestDay,
		"chart_data":       chartData,
		"payment_methods":  paymentMethods,
		"top_transactions": topTx,
	})
}

// GET /api/v1/analytics/:user_id/summary — month-over-month comparison
func getSummary(c *gin.Context) {
	userID := c.Param("user_id")

	now := time.Now()
	thisMonthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	lastMonthStart := thisMonthStart.AddDate(0, -1, 0)

	var thisRevenue, lastRevenue float64
	var thisTx, lastTx int

	db.QueryRow(`SELECT COALESCE(SUM(amount),0) FROM payments WHERE receiver_user_id=$1 AND created_at>=$2 AND status='success'`,
		userID, thisMonthStart).Scan(&thisRevenue)
	db.QueryRow(`SELECT COUNT(*) FROM payments WHERE receiver_user_id=$1 AND created_at>=$2 AND status='success'`,
		userID, thisMonthStart).Scan(&thisTx)
	db.QueryRow(`SELECT COALESCE(SUM(amount),0) FROM payments WHERE receiver_user_id=$1 AND created_at>=$2 AND created_at<$3 AND status='success'`,
		userID, lastMonthStart, thisMonthStart).Scan(&lastRevenue)
	db.QueryRow(`SELECT COUNT(*) FROM payments WHERE receiver_user_id=$1 AND created_at>=$2 AND created_at<$3 AND status='success'`,
		userID, lastMonthStart, thisMonthStart).Scan(&lastTx)

	revenueGrowth := 0.0
	if lastRevenue > 0 {
		revenueGrowth = (thisRevenue - lastRevenue) / lastRevenue * 100
	}
	txGrowth := 0.0
	if lastTx > 0 {
		txGrowth = float64(thisTx-lastTx) / float64(lastTx) * 100
	}

	c.JSON(http.StatusOK, gin.H{
		"this_month_revenue": thisRevenue,
		"last_month_revenue": lastRevenue,
		"this_month_tx":      thisTx,
		"last_month_tx":      lastTx,
		"revenue_growth":     revenueGrowth,
		"tx_growth":          txGrowth,
	})
}

// GET /api/v1/analytics/admin/overview — platform-wide stats for admin dashboard
func getAdminOverview(c *gin.Context) {
	// Total revenue (all successful payments)
	var totalRevenue float64
	db.QueryRow(`SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='success'`).Scan(&totalRevenue)

	// Total transactions
	var totalTx int
	db.QueryRow(`SELECT COUNT(*) FROM payments WHERE status='success'`).Scan(&totalTx)

	// Success rate
	var allTx int
	db.QueryRow(`SELECT COUNT(*) FROM payments`).Scan(&allTx)
	successRate := 0.0
	if allTx > 0 {
		successRate = float64(totalTx) / float64(allTx) * 100
	}

	// Active users (at least 1 payment in last 30 days)
	var activeUsers int
	thirtyDaysAgo := time.Now().AddDate(0, -1, 0)
	db.QueryRow(`
		SELECT COUNT(DISTINCT u.id)
		FROM users u
		WHERE EXISTS (
			SELECT 1 FROM payments p
			WHERE (p.sender_user_id=u.id OR p.receiver_user_id=u.id)
			AND p.created_at >= $1
		)
	`, thirtyDaysAgo).Scan(&activeUsers)

	// Total users
	var totalUsers int
	db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&totalUsers)

	// Merchant collections (revenue received by merchants)
	var merchantRevenue float64
	db.QueryRow(`
		SELECT COALESCE(SUM(p.amount),0)
		FROM payments p
		JOIN users u ON u.id = p.receiver_user_id
		WHERE u.role = 'merchant' AND p.status = 'success'
	`).Scan(&merchantRevenue)

	// Today's revenue
	todayStart := time.Now().Truncate(24 * time.Hour)
	var todayRevenue float64
	db.QueryRow(`SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='success' AND created_at>=$1`, todayStart).Scan(&todayRevenue)

	// Today's transaction count
	var todayTx int
	db.QueryRow(`SELECT COUNT(*) FROM payments WHERE status='success' AND created_at>=$1`, todayStart).Scan(&todayTx)

	// Revenue chart: last 30 days daily
	rows, _ := db.Query(`
		SELECT DATE(created_at) AS day, COALESCE(SUM(amount),0)
		FROM payments
		WHERE status='success' AND created_at >= $1
		GROUP BY day ORDER BY day ASC
	`, thirtyDaysAgo)

	var revenueChart []map[string]interface{}
	if rows != nil {
		defer rows.Close()
		for rows.Next() {
			var day time.Time
			var amt float64
			rows.Scan(&day, &amt)
			revenueChart = append(revenueChart, map[string]interface{}{
				"day":    day.Format("2 Jan"),
				"amount": amt,
			})
		}
	}
	if revenueChart == nil {
		revenueChart = []map[string]interface{}{}
	}

	c.JSON(http.StatusOK, gin.H{
		"total_revenue":      totalRevenue,
		"total_transactions": totalTx,
		"success_rate":       successRate,
		"active_users":       activeUsers,
		"total_users":        totalUsers,
		"merchant_revenue":   merchantRevenue,
		"today_revenue":      todayRevenue,
		"today_tx":           todayTx,
		"revenue_chart":      revenueChart,
	})
}

func formatTime(t time.Time) string {
	diff := time.Since(t)
	if diff.Hours() < 24 {
		return "Today, " + t.Format("03:04 PM")
	} else if diff.Hours() < 48 {
		return "Yesterday, " + t.Format("03:04 PM")
	}
	return t.Format("2 Jan, 03:04 PM")
}
