package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func CreateWallet(c *gin.Context) {
	var req CreateWalletRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	walletID := uuid.New().String()
	query := `INSERT INTO wallets (id, user_id, balance, currency, is_frozen, daily_limit)
			  VALUES ($1, $2, $3, $4, $5, $6)`
	_, err := DB.Exec(query, walletID, req.UserID, 0.00, "INR", false, 10000.00)
	if err != nil {
		log.Println("Wallet create error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Wallet creation failed"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{
		"message":   "Wallet created successfully",
		"wallet_id": walletID,
	})
}

func GetWallet(c *gin.Context) {
	userID := c.Param("user_id")
	var wallet Wallet
	query := `SELECT id, user_id, balance, currency, is_frozen, daily_limit, created_at 
			  FROM wallets WHERE user_id = $1`
	err := DB.QueryRow(query, userID).Scan(
		&wallet.ID, &wallet.UserID, &wallet.Balance,
		&wallet.Currency, &wallet.IsFrozen, &wallet.DailyLimit,
		&wallet.CreatedAt,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Wallet not found"})
		return
	}
	c.JSON(http.StatusOK, wallet)
}

func SendMoney(c *gin.Context) {
	var req SendMoneyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if !isValidPhone(req.ReceiverPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Receiver phone must be exactly 10 digits"})
		return
	}
	if req.Amount < 1 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Minimum transfer amount is ₹1"})
		return
	}
	if req.Amount > 100000 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Maximum transfer amount is ₹1,00,000 per transaction"})
		return
	}
	var senderWallet Wallet
	query := `SELECT id, balance, is_frozen FROM wallets WHERE user_id = $1`
	err := DB.QueryRow(query, req.SenderUserID).Scan(
		&senderWallet.ID, &senderWallet.Balance, &senderWallet.IsFrozen,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Sender wallet not found"})
		return
	}
	if senderWallet.IsFrozen {
		c.JSON(http.StatusForbidden, gin.H{"error": "Sender wallet is frozen"})
		return
	}
	if senderWallet.Balance < req.Amount {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient balance"})
		return
	}
	var receiverUserID string
	userQuery := `SELECT id FROM users WHERE phone = $1`
	err = DB.QueryRow(userQuery, req.ReceiverPhone).Scan(&receiverUserID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Receiver not found"})
		return
	}
	var senderName string
	DB.QueryRow(`SELECT full_name FROM users WHERE id = $1`, req.SenderUserID).Scan(&senderName)

	tx, err := DB.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Transaction failed"})
		return
	}
	_, err = tx.Exec(`UPDATE wallets SET balance = balance - $1 WHERE user_id = $2`,
		req.Amount, req.SenderUserID)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Payment failed"})
		return
	}
	_, err = tx.Exec(`UPDATE wallets SET balance = balance + $1 WHERE user_id = $2`,
		req.Amount, receiverUserID)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Payment failed"})
		return
	}
	paymentID := uuid.New().String()
	_, err = tx.Exec(`INSERT INTO payments (id, sender_user_id, receiver_user_id, amount, currency, status, description)
					  VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		paymentID, req.SenderUserID, receiverUserID, req.Amount, "INR", "success", req.Description)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Payment recording failed"})
		return
	}
	tx.Commit()

	go func() {
		notifBody := fmt.Sprintf(`{
			"user_id": "%s",
			"title": "Money Received! 💰",
			"message": "You received ₹%.2f from %s",
			"type": "credit"
		}`, receiverUserID, req.Amount, senderName)
		resp, err := http.Post(
			"http://localhost:8004/api/v1/notifications/send",
			"application/json",
			strings.NewReader(notifBody),
		)
		if err != nil {
			log.Println("Notification error:", err)
			return
		}
		defer resp.Body.Close()
		log.Println("Notification sent to receiver:", receiverUserID)
	}()

	go func() {
		notifBody := fmt.Sprintf(`{
			"user_id": "%s",
			"title": "Money Sent! ✅",
			"message": "₹%.2f sent successfully",
			"type": "debit"
		}`, req.SenderUserID, req.Amount)
		resp, err := http.Post(
			"http://localhost:8004/api/v1/notifications/send",
			"application/json",
			strings.NewReader(notifBody),
		)
		if err != nil {
			log.Println("Notification error:", err)
			return
		}
		defer resp.Body.Close()
	}()

	c.JSON(http.StatusOK, gin.H{
		"message":    "Payment successful",
		"payment_id": paymentID,
		"amount":     req.Amount,
		"status":     "success",
	})
}

func GetPaymentHistory(c *gin.Context) {
	userID := c.Param("user_id")
	rows, err := DB.Query(`SELECT id, sender_user_id, receiver_user_id, amount, currency, status, description, created_at 
						   FROM payments WHERE sender_user_id = $1 OR receiver_user_id = $1 
						   ORDER BY created_at DESC`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get payment history"})
		return
	}
	defer rows.Close()
	var payments []Payment
	for rows.Next() {
		var p Payment
		rows.Scan(&p.ID, &p.SenderUserID, &p.ReceiverUserID,
			&p.Amount, &p.Currency, &p.Status, &p.Description, &p.CreatedAt)
		payments = append(payments, p)
	}
	c.JSON(http.StatusOK, gin.H{
		"payments": payments,
		"count":    len(payments),
	})
}

func AddMoney(c *gin.Context) {
	var req struct {
		UserID string  `json:"user_id"`
		Amount float64 `json:"amount"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.Amount < 1 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Minimum add amount is ₹1"})
		return
	}
	if req.Amount > 100000 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Maximum add amount is ₹1,00,000 at a time"})
		return
	}
	var walletID string
	err := DB.QueryRow("SELECT id FROM wallets WHERE user_id = $1", req.UserID).Scan(&walletID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Wallet not found"})
		return
	}
	_, err = DB.Exec("UPDATE wallets SET balance = balance + $1 WHERE user_id = $2",
		req.Amount, req.UserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add money"})
		return
	}
	var newBalance float64
	DB.QueryRow("SELECT balance FROM wallets WHERE user_id = $1", req.UserID).Scan(&newBalance)

	go func() {
		notifBody := fmt.Sprintf(`{
			"user_id": "%s",
			"title": "Money Added! 💳",
			"message": "₹%.2f added to your OB Pay wallet",
			"type": "credit"
		}`, req.UserID, req.Amount)
		resp, err := http.Post(
			"http://localhost:8004/api/v1/notifications/send",
			"application/json",
			strings.NewReader(notifBody),
		)
		if err != nil {
			log.Println("Notification error:", err)
			return
		}
		defer resp.Body.Close()
	}()

	c.JSON(http.StatusOK, gin.H{
		"message":     "Money added successfully",
		"amount":      req.Amount,
		"new_balance": newBalance,
	})
}

func GetAllTransactions(c *gin.Context) {
	rows, err := DB.Query(`
		SELECT p.id, p.sender_user_id, p.receiver_user_id,
		       p.amount, p.currency, p.status, p.description, p.created_at,
		       u1.full_name as sender_name, u2.full_name as receiver_name,
		       COALESCE(u1.role, 'user') as sender_role,
		       COALESCE(u2.role, 'user') as receiver_role
		FROM payments p
		LEFT JOIN users u1 ON p.sender_user_id = u1.id
		LEFT JOIN users u2 ON p.receiver_user_id = u2.id
		ORDER BY p.created_at DESC`)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to get transactions"})
		return
	}
	defer rows.Close()

	var payments []gin.H
	for rows.Next() {
		var id, senderID, receiverID, currency, status, description string
		var senderName, receiverName, senderRole, receiverRole string
		var amount float64
		var createdAt interface{}
		rows.Scan(&id, &senderID, &receiverID, &amount, &currency,
			&status, &description, &createdAt, &senderName, &receiverName,
			&senderRole, &receiverRole)
		payments = append(payments, gin.H{
			"id":               id,
			"sender_user_id":   senderID,
			"receiver_user_id": receiverID,
			"sender_name":      senderName,
			"receiver_name":    receiverName,
			"sender_role":      senderRole,
			"receiver_role":    receiverRole,
			"amount":           amount,
			"currency":         currency,
			"status":           status,
			"description":      description,
			"created_at":       createdAt,
		})
	}
	c.JSON(200, gin.H{"payments": payments, "count": len(payments)})
}

func GetAdminPaymentStats(c *gin.Context) {
	var totalTransactions int
	var totalRevenue float64
	DB.QueryRow(`SELECT COUNT(*) FROM payments WHERE status = 'success'`).Scan(&totalTransactions)
	DB.QueryRow(`SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'success'`).Scan(&totalRevenue)

	c.JSON(200, gin.H{
		"total_transactions": totalTransactions,
		"total_revenue":      totalRevenue,
	})
}
