package main

import (
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func CreateTransaction(c *gin.Context) {
	var tx Transaction

	if err := c.ShouldBindJSON(&tx); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	tx.ID = uuid.New().String()
	tx.Currency = "INR"

	var refID interface{}
	if tx.ReferenceID != "" {
		refID = tx.ReferenceID
	} else {
		refID = nil
	}

	query := `INSERT INTO transactions 
		(id, user_id, type, amount, currency, status, reference_id, description, 
		sender_user_id, receiver_user_id, payment_method, balance_before, balance_after)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`

	_, err := DB.Exec(query,
		tx.ID, tx.UserID, tx.Type, tx.Amount, tx.Currency,
		tx.Status, refID, tx.Description,
		tx.SenderUserID, tx.ReceiverUserID,
		tx.PaymentMethod, tx.BalanceBefore, tx.BalanceAfter,
	)
	if err != nil {
		log.Println("Create transaction error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Transaction creation failed",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":        "Transaction created successfully",
		"transaction_id": tx.ID,
	})
}

func GetTransactions(c *gin.Context) {
	userID := c.Query("user_id")
	status := c.Query("status")
	txType := c.Query("type")
	limitStr := c.Query("limit")

	limit := 20
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil {
			limit = l
		}
	}

	query := `SELECT id, user_id, type, amount, currency, status, 
		COALESCE(description,''), COALESCE(sender_user_id::text,''), 
		COALESCE(receiver_user_id::text,''),
		payment_method, balance_before, balance_after, created_at
		FROM transactions WHERE user_id = $1`

	args := []interface{}{userID}
	argCount := 2

	if status != "" {
		query += ` AND status = $` + strconv.Itoa(argCount)
		args = append(args, status)
		argCount++
	}

	if txType != "" {
		query += ` AND type = $` + strconv.Itoa(argCount)
		args = append(args, txType)
		argCount++
	}

	query += ` ORDER BY created_at DESC LIMIT $` + strconv.Itoa(argCount)
	args = append(args, limit)

	rows, err := DB.Query(query, args...)
	if err != nil {
		log.Println("Get transactions error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get transactions",
		})
		return
	}
	defer rows.Close()

	var transactions []Transaction
	for rows.Next() {
		var tx Transaction
		rows.Scan(
			&tx.ID, &tx.UserID, &tx.Type, &tx.Amount,
			&tx.Currency, &tx.Status, &tx.Description,
			&tx.SenderUserID, &tx.ReceiverUserID,
			&tx.PaymentMethod, &tx.BalanceBefore,
			&tx.BalanceAfter, &tx.CreatedAt,
		)
		transactions = append(transactions, tx)
	}

	c.JSON(http.StatusOK, gin.H{
		"transactions": transactions,
		"count":        len(transactions),
	})
}

func GetTransactionByID(c *gin.Context) {
	txID := c.Param("id")

	var tx Transaction
	query := `SELECT id, user_id, type, amount, currency, status,
		COALESCE(description,''), COALESCE(sender_user_id::text,''),
		COALESCE(receiver_user_id::text,''),
		payment_method, balance_before, balance_after, created_at
		FROM transactions WHERE id = $1`

	err := DB.QueryRow(query, txID).Scan(
		&tx.ID, &tx.UserID, &tx.Type, &tx.Amount,
		&tx.Currency, &tx.Status, &tx.Description,
		&tx.SenderUserID, &tx.ReceiverUserID,
		&tx.PaymentMethod, &tx.BalanceBefore,
		&tx.BalanceAfter, &tx.CreatedAt,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "Transaction not found",
		})
		return
	}

	c.JSON(http.StatusOK, tx)
}

func GetTransactionSummary(c *gin.Context) {
	userID := c.Param("user_id")

	var summary TransactionSummary

	query := `SELECT 
		COALESCE(SUM(CASE WHEN type='credit' AND status='success' THEN amount ELSE 0 END), 0),
		COALESCE(SUM(CASE WHEN type='debit' AND status='success' THEN amount ELSE 0 END), 0),
		COUNT(*),
		COUNT(CASE WHEN status='success' THEN 1 END),
		COUNT(CASE WHEN status='failed' THEN 1 END),
		COUNT(CASE WHEN status='pending' THEN 1 END)
		FROM transactions WHERE user_id = $1`

	err := DB.QueryRow(query, userID).Scan(
		&summary.TotalCredit,
		&summary.TotalDebit,
		&summary.TotalTransactions,
		&summary.SuccessCount,
		&summary.FailedCount,
		&summary.PendingCount,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get summary",
		})
		return
	}

	c.JSON(http.StatusOK, summary)
}

func UpdateTransactionStatus(c *gin.Context) {
	txID := c.Param("id")

	var body struct {
		Status string `json:"status" binding:"required"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := `UPDATE transactions SET status = $1, updated_at = NOW() WHERE id = $2`
	_, err := DB.Exec(query, body.Status, txID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Status update failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Transaction status updated",
		"status":  body.Status,
	})
}
