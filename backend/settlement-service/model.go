package main

import "time"

type Settlement struct {
	ID             string    `json:"id"`
	MerchantID     string    `json:"merchant_id"`
	Amount         float64   `json:"amount"`
	Fee            float64   `json:"fee"`
	NetAmount      float64   `json:"net_amount"`
	Status         string    `json:"status"` // pending, processing, completed, failed
	BankAccount    string    `json:"bank_account"`
	IFSCCode       string    `json:"ifsc_code"`
	BankName       string    `json:"bank_name"`
	UTRNumber      string    `json:"utr_number"` // Unique Transaction Reference
	SettlementDate time.Time `json:"settlement_date"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type SettlementRequest struct {
	MerchantID  string  `json:"merchant_id" binding:"required"`
	Amount      float64 `json:"amount" binding:"required"`
	BankAccount string  `json:"bank_account" binding:"required"`
	IFSCCode    string  `json:"ifsc_code" binding:"required"`
	BankName    string  `json:"bank_name" binding:"required"`
}

type SettlementSummary struct {
	TotalSettled   float64 `json:"total_settled"`
	TotalFees      float64 `json:"total_fees"`
	TotalNetAmount float64 `json:"total_net_amount"`
	PendingCount   int     `json:"pending_count"`
	CompletedCount int     `json:"completed_count"`
}
