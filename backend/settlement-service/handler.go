package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func RequestSettlement(c *gin.Context) {
	var req SettlementRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// Calculate fee (1%)
	fee := req.Amount * 0.01
	netAmount := req.Amount - fee

	id := uuid.New().String()

	query := `INSERT INTO settlements
		(id, merchant_id, amount, fee, net_amount, status, bank_account, ifsc_code, bank_name)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`

	_, err := DB.Exec(query,
		id, req.MerchantID, req.Amount, fee, netAmount,
		"pending", req.BankAccount, req.IFSCCode, req.BankName,
	)
	if err != nil {
		log.Println("Settlement request error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Settlement request failed",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":       "Settlement requested successfully",
		"settlement_id": id,
		"amount":        req.Amount,
		"fee":           fee,
		"net_amount":    netAmount,
		"status":        "pending",
		"note":          "Amount will be credited within T+1 business day",
	})
}

func GetSettlements(c *gin.Context) {
	merchantID := c.Param("merchant_id")

	rows, err := DB.Query(`
		SELECT id, merchant_id, amount, fee, net_amount, status,
		bank_account, ifsc_code, bank_name,
		COALESCE(utr_number, ''),
		created_at
		FROM settlements
		WHERE merchant_id = $1
		ORDER BY created_at DESC`, merchantID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get settlements",
		})
		return
	}
	defer rows.Close()

	var settlements []Settlement
	for rows.Next() {
		var s Settlement
		rows.Scan(
			&s.ID, &s.MerchantID, &s.Amount, &s.Fee,
			&s.NetAmount, &s.Status, &s.BankAccount,
			&s.IFSCCode, &s.BankName, &s.UTRNumber,
			&s.CreatedAt,
		)
		settlements = append(settlements, s)
	}

	c.JSON(http.StatusOK, gin.H{
		"settlements": settlements,
		"count":       len(settlements),
	})
}

func ProcessSettlement(c *gin.Context) {
	id := c.Param("id")

	// Generate UTR number
	utrNumber := fmt.Sprintf("UTR%d", time.Now().Unix())

	query := `UPDATE settlements 
		SET status = 'completed', 
		utr_number = $1,
		settlement_date = NOW(),
		updated_at = NOW()
		WHERE id = $2`

	_, err := DB.Exec(query, utrNumber, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Settlement processing failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Settlement processed successfully",
		"utr_number": utrNumber,
		"status":     "completed",
	})
}

func GetSettlementSummary(c *gin.Context) {
	merchantID := c.Param("merchant_id")

	var summary SettlementSummary

	err := DB.QueryRow(`
		SELECT
		COALESCE(SUM(CASE WHEN status='completed' THEN amount ELSE 0 END), 0),
		COALESCE(SUM(CASE WHEN status='completed' THEN fee ELSE 0 END), 0),
		COALESCE(SUM(CASE WHEN status='completed' THEN net_amount ELSE 0 END), 0),
		COUNT(CASE WHEN status='pending' THEN 1 END),
		COUNT(CASE WHEN status='completed' THEN 1 END)
		FROM settlements WHERE merchant_id = $1`, merchantID).Scan(
		&summary.TotalSettled,
		&summary.TotalFees,
		&summary.TotalNetAmount,
		&summary.PendingCount,
		&summary.CompletedCount,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get summary",
		})
		return
	}

	c.JSON(http.StatusOK, summary)
}
