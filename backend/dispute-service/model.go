package main

import "time"

type Dispute struct {
	ID            string     `json:"id"`
	UserID        string     `json:"user_id"`
	TransactionID string     `json:"transaction_id"`
	Type          string     `json:"type"`   // chargeback, fraud, wrong_payment, other
	Status        string     `json:"status"` // open, investigating, resolved, rejected
	Title         string     `json:"title"`
	Description   string     `json:"description"`
	Amount        float64    `json:"amount"`
	Resolution    string     `json:"resolution"`
	ResolvedAt    *time.Time `json:"resolved_at"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
}

type DisputeRequest struct {
	UserID        string  `json:"user_id" binding:"required"`
	TransactionID string  `json:"transaction_id" binding:"required"`
	Type          string  `json:"type" binding:"required"`
	Title         string  `json:"title" binding:"required"`
	Description   string  `json:"description" binding:"required"`
	Amount        float64 `json:"amount" binding:"required"`
}

type ResolveDisputeRequest struct {
	DisputeID  string `json:"dispute_id" binding:"required"`
	Status     string `json:"status" binding:"required"`
	Resolution string `json:"resolution" binding:"required"`
}
