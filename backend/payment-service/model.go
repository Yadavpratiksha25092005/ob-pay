package main

import "time"

type Wallet struct {
	ID         string    `json:"id"`
	UserID     string    `json:"user_id"`
	Balance    float64   `json:"balance"`
	Currency   string    `json:"currency"`
	IsFrozen   bool      `json:"is_frozen"`
	DailyLimit float64   `json:"daily_limit"`
	CreatedAt  time.Time `json:"created_at"`
}

type Payment struct {
	ID             string    `json:"id"`
	SenderUserID   string    `json:"sender_user_id"`
	ReceiverUserID string    `json:"receiver_user_id"`
	Amount         float64   `json:"amount"`
	Currency       string    `json:"currency"`
	Status         string    `json:"status"`
	Description    string    `json:"description"`
	CreatedAt      time.Time `json:"created_at"`
}

type SendMoneyRequest struct {
	SenderUserID  string  `json:"sender_user_id" binding:"required"`
	ReceiverPhone string  `json:"receiver_phone" binding:"required"`
	Amount        float64 `json:"amount" binding:"required"`
	Description   string  `json:"description"`
}

type CreateWalletRequest struct {
	UserID string `json:"user_id" binding:"required"`
}
