package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func CheckCompliance(c *gin.Context) {
	var req ComplianceCheckRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// Calculate risk score
	riskScore := calculateRiskScore(req.Amount, req.UserID)
	riskLevel := getRiskLevel(riskScore)
	status := "passed"
	reason := "Transaction within normal limits"

	// AML check — large transaction
	if req.Amount >= 1000000 { // 10 lakh
		status = "review"
		reason = "Large transaction — AML review required"
		riskScore = 80

		// Create AML report
		amlID := uuid.New().String()
		DB.Exec(`INSERT INTO aml_reports
			(id, user_id, transaction_id, amount, report_type, status, description)
			VALUES ($1,$2,$3,$4,$5,$6,$7)`,
			amlID, req.UserID, req.TransactionID,
			req.Amount, "CTR", "pending",
			"Large transaction detected — CTR filing required",
		)
	}

	// Fraud check — suspicious amount
	if req.Amount >= 500000 { // 5 lakh
		riskScore = 60
		riskLevel = "medium"

		// Create fraud alert
		alertID := uuid.New().String()
		DB.Exec(`INSERT INTO fraud_alerts
			(id, user_id, transaction_id, alert_type, severity, description)
			VALUES ($1,$2,$3,$4,$5,$6)`,
			alertID, req.UserID, req.TransactionID,
			"high_value", "medium",
			"High value transaction detected",
		)
	}

	// Save compliance check
	id := uuid.New().String()
	var txID interface{}
	if req.TransactionID != "" {
		txID = req.TransactionID
	} else {
		txID = nil
	}

	_, err := DB.Exec(`INSERT INTO compliance_checks
		(id, user_id, transaction_id, check_type, status, risk_score, risk_level, reason)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
		id, req.UserID, txID, req.CheckType,
		status, riskScore, riskLevel, reason,
	)
	if err != nil {
		log.Println("Compliance check error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Compliance check failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"check_id":   id,
		"status":     status,
		"risk_score": riskScore,
		"risk_level": riskLevel,
		"reason":     reason,
		"allowed":    status != "failed",
	})
}

func calculateRiskScore(amount float64, userID string) int {
	score := 0

	// Amount based risk
	if amount > 100000 {
		score += 30
	} else if amount > 50000 {
		score += 20
	} else if amount > 10000 {
		score += 10
	}

	// Check transaction frequency
	var count int
	DB.QueryRow(`SELECT COUNT(*) FROM compliance_checks 
		WHERE user_id = $1 
		AND created_at > NOW() - INTERVAL '1 hour'`, userID).Scan(&count)

	if count > 10 {
		score += 40
	} else if count > 5 {
		score += 20
	}

	return score
}

func getRiskLevel(score int) string {
	if score >= 70 {
		return "high"
	} else if score >= 40 {
		return "medium"
	}
	return "low"
}

func GetComplianceHistory(c *gin.Context) {
	userID := c.Param("user_id")

	rows, err := DB.Query(`
		SELECT id, user_id, check_type, status,
		risk_score, risk_level, COALESCE(reason,''), created_at
		FROM compliance_checks
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT 50`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get compliance history",
		})
		return
	}
	defer rows.Close()

	var checks []ComplianceCheck
	for rows.Next() {
		var ch ComplianceCheck
		rows.Scan(
			&ch.ID, &ch.UserID, &ch.CheckType,
			&ch.Status, &ch.RiskScore, &ch.RiskLevel,
			&ch.Reason, &ch.CreatedAt,
		)
		checks = append(checks, ch)
	}

	c.JSON(http.StatusOK, gin.H{
		"checks": checks,
		"count":  len(checks),
	})
}

func GetFraudAlerts(c *gin.Context) {
	userID := c.Param("user_id")

	rows, err := DB.Query(`
		SELECT id, user_id, alert_type, severity,
		COALESCE(description,''), is_resolved, created_at
		FROM fraud_alerts
		WHERE user_id = $1
		ORDER BY created_at DESC`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get fraud alerts",
		})
		return
	}
	defer rows.Close()

	var alerts []FraudAlert
	for rows.Next() {
		var a FraudAlert
		rows.Scan(
			&a.ID, &a.UserID, &a.AlertType,
			&a.Severity, &a.Description,
			&a.IsResolved, &a.CreatedAt,
		)
		alerts = append(alerts, a)
	}

	c.JSON(http.StatusOK, gin.H{
		"alerts": alerts,
		"count":  len(alerts),
	})
}

func GetAMLReports(c *gin.Context) {
	rows, err := DB.Query(`
		SELECT id, user_id, amount, report_type,
		status, COALESCE(description,''), created_at
		FROM aml_reports
		ORDER BY created_at DESC
		LIMIT 100`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get AML reports",
		})
		return
	}
	defer rows.Close()

	var reports []AMLReport
	for rows.Next() {
		var r AMLReport
		rows.Scan(
			&r.ID, &r.UserID, &r.Amount,
			&r.ReportType, &r.Status,
			&r.Description, &r.CreatedAt,
		)
		reports = append(reports, r)
	}

	c.JSON(http.StatusOK, gin.H{
		"reports": reports,
		"count":   len(reports),
	})
}

func GetRiskScore(c *gin.Context) {
	userID := c.Param("user_id")

	var avgScore float64
	var totalChecks int
	var highRiskCount int

	DB.QueryRow(`
		SELECT 
		COALESCE(AVG(risk_score), 0),
		COUNT(*),
		COUNT(CASE WHEN risk_level='high' THEN 1 END)
		FROM compliance_checks
		WHERE user_id = $1`, userID).Scan(
		&avgScore, &totalChecks, &highRiskCount,
	)

	riskLevel := getRiskLevel(int(avgScore))

	c.JSON(http.StatusOK, gin.H{
		"user_id":         userID,
		"avg_risk_score":  avgScore,
		"risk_level":      riskLevel,
		"total_checks":    totalChecks,
		"high_risk_count": highRiskCount,
	})
}
