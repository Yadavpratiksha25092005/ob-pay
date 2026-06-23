package main

import "time"

type Notification struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Type      string    `json:"type"`     // sms, email, push
	Category  string    `json:"category"` // payment, kyc, security, promo
	Title     string    `json:"title"`
	Message   string    `json:"message"`
	Status    string    `json:"status"` // pending, sent, failed
	IsRead    bool      `json:"is_read"`
	CreatedAt time.Time `json:"created_at"`
}

type SendNotificationRequest struct {
	UserID   string `json:"user_id" binding:"required"`
	Type     string `json:"type" binding:"required"`
	Category string `json:"category" binding:"required"`
	Title    string `json:"title" binding:"required"`
	Message  string `json:"message" binding:"required"`
}

// Payment notification templates
type PaymentNotification struct {
	UserID       string  `json:"user_id" binding:"required"`
	Amount       float64 `json:"amount" binding:"required"`
	Type         string  `json:"type"` // sent, received
	ReceiverName string  `json:"receiver_name"`
	SenderName   string  `json:"sender_name"`
	PaymentID    string  `json:"payment_id"`
}
