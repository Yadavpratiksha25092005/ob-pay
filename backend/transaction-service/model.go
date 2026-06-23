package main

import "time"

type Transaction struct {
	ID             string    `json:"id"`
	UserID         string    `json:"user_id"`
	Type           string    `json:"type"` // credit, debit
	Amount         float64   `json:"amount"`
	Currency       string    `json:"currency"`
	Status         string    `json:"status"` // pending, success, failed, reversed
	ReferenceID    string    `json:"reference_id"`
	Description    string    `json:"description"`
	SenderUserID   string    `json:"sender_user_id"`
	ReceiverUserID string    `json:"receiver_user_id"`
	PaymentMethod  string    `json:"payment_method"` // upi, wallet, card
	BalanceBefore  float64   `json:"balance_before"`
	BalanceAfter   float64   `json:"balance_after"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type TransactionFilter struct {
	UserID    string `form:"user_id"`
	Status    string `form:"status"`
	Type      string `form:"type"`
	StartDate string `form:"start_date"`
	EndDate   string `form:"end_date"`
	Limit     int    `form:"limit"`
	Offset    int    `form:"offset"`
}

type TransactionSummary struct {
	TotalCredit       float64 `json:"total_credit"`
	TotalDebit        float64 `json:"total_debit"`
	TotalTransactions int     `json:"total_transactions"`
	SuccessCount      int     `json:"success_count"`
	FailedCount       int     `json:"failed_count"`
	PendingCount      int     `json:"pending_count"`
}
