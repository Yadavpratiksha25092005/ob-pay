package main

import "time"

type ComplianceCheck struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	TransactionID string    `json:"transaction_id"`
	CheckType     string    `json:"check_type"` // aml, fraud, kyc, limit
	Status        string    `json:"status"`     // passed, failed, review
	RiskScore     int       `json:"risk_score"` // 0-100
	RiskLevel     string    `json:"risk_level"` // low, medium, high
	Reason        string    `json:"reason"`
	CreatedAt     time.Time `json:"created_at"`
}

type AMLReport struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	TransactionID string    `json:"transaction_id"`
	Amount        float64   `json:"amount"`
	ReportType    string    `json:"report_type"` // STR, CTR
	Status        string    `json:"status"`      // pending, reported, closed
	Description   string    `json:"description"`
	CreatedAt     time.Time `json:"created_at"`
}

type FraudAlert struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	TransactionID string    `json:"transaction_id"`
	AlertType     string    `json:"alert_type"` // velocity, device, location, pattern
	Severity      string    `json:"severity"`   // low, medium, high, critical
	Description   string    `json:"description"`
	IsResolved    bool      `json:"is_resolved"`
	CreatedAt     time.Time `json:"created_at"`
}

type ComplianceCheckRequest struct {
	UserID        string  `json:"user_id" binding:"required"`
	TransactionID string  `json:"transaction_id"`
	Amount        float64 `json:"amount" binding:"required"`
	CheckType     string  `json:"check_type" binding:"required"`
}

type RiskScoreRequest struct {
	UserID string `json:"user_id" binding:"required"`
}
