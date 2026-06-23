package main

import (
	"database/sql"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func RaiseDispute(c *gin.Context) {
	var req DisputeRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	id := uuid.New().String()

	query := `INSERT INTO disputes
		(id, user_id, transaction_id, type, status, title, description, amount)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`

	_, err := DB.Exec(query,
		id, req.UserID, req.TransactionID, req.Type,
		"open", req.Title, req.Description, req.Amount,
	)
	if err != nil {
		log.Println("Raise dispute error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Dispute creation failed",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":    "Dispute raised successfully",
		"dispute_id": id,
		"status":     "open",
		"note":       "Your dispute will be reviewed within 3-5 business days",
	})
}

func GetDisputes(c *gin.Context) {
	userID := c.Param("user_id")

	rows, err := DB.Query(`
		SELECT id, user_id, transaction_id, type, status,
		title, description, amount,
		COALESCE(resolution,''), created_at
		FROM disputes WHERE user_id = $1
		ORDER BY created_at DESC`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get disputes",
		})
		return
	}
	defer rows.Close()

	var disputes []Dispute
	for rows.Next() {
		var d Dispute
		rows.Scan(
			&d.ID, &d.UserID, &d.TransactionID,
			&d.Type, &d.Status, &d.Title,
			&d.Description, &d.Amount,
			&d.Resolution, &d.CreatedAt,
		)
		disputes = append(disputes, d)
	}

	c.JSON(http.StatusOK, gin.H{
		"disputes": disputes,
		"count":    len(disputes),
	})
}

func GetDisputeByID(c *gin.Context) {
	id := c.Param("id")

	var d Dispute
	err := DB.QueryRow(`
		SELECT id, user_id, transaction_id, type, status,
		title, description, amount,
		COALESCE(resolution,''), created_at
		FROM disputes WHERE id = $1`, id).Scan(
		&d.ID, &d.UserID, &d.TransactionID,
		&d.Type, &d.Status, &d.Title,
		&d.Description, &d.Amount,
		&d.Resolution, &d.CreatedAt,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "Dispute not found",
		})
		return
	}

	c.JSON(http.StatusOK, d)
}

func ResolveDispute(c *gin.Context) {
	var req ResolveDisputeRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	now := time.Now()

	_, err := DB.Exec(`
		UPDATE disputes 
		SET status = $1, resolution = $2, 
		resolved_at = $3, updated_at = NOW()
		WHERE id = $4`,
		req.Status, req.Resolution, now, req.DisputeID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Dispute resolution failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Dispute " + req.Status + " successfully",
		"dispute_id": req.DisputeID,
		"status":     req.Status,
		"resolution": req.Resolution,
	})
}

func GetAllDisputes(c *gin.Context) {
	status := c.Query("status")

	query := `SELECT id, user_id, transaction_id, type, status,
		title, description, amount,
		COALESCE(resolution,''), created_at
		FROM disputes`

	var rows *sql.Rows
	var err error

	if status != "" {
		query += ` WHERE status = $1 ORDER BY created_at DESC`
		rows, err = DB.Query(query, status)
	} else {
		query += ` ORDER BY created_at DESC LIMIT 100`
		rows, err = DB.Query(query)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get disputes",
		})
		return
	}
	defer rows.Close()

	var disputes []Dispute
	for rows.Next() {
		var d Dispute
		rows.Scan(
			&d.ID, &d.UserID, &d.TransactionID,
			&d.Type, &d.Status, &d.Title,
			&d.Description, &d.Amount,
			&d.Resolution, &d.CreatedAt,
		)
		disputes = append(disputes, d)
	}

	c.JSON(http.StatusOK, gin.H{
		"disputes": disputes,
		"count":    len(disputes),
	})
}
