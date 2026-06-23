package main

import "time"

type KYCDocument struct {
	ID              string     `json:"id"`
	UserID          string     `json:"user_id"`
	DocumentType    string     `json:"document_type"` // aadhaar, pan, passport
	DocumentNumber  string     `json:"document_number"`
	Status          string     `json:"status"` // pending, verified, rejected
	RejectionReason string     `json:"rejection_reason"`
	VerifiedAt      *time.Time `json:"verified_at"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

type KYCProfile struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	FullName      string    `json:"full_name"`
	DateOfBirth   string    `json:"date_of_birth"`
	Gender        string    `json:"gender"`
	Address       string    `json:"address"`
	AadhaarNumber string    `json:"aadhaar_number"`
	PANNumber     string    `json:"pan_number"`
	KYCStatus     string    `json:"kyc_status"` // pending, basic, full
	RiskLevel     string    `json:"risk_level"` // low, medium, high
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type KYCRequest struct {
	UserID        string `json:"user_id" binding:"required"`
	FullName      string `json:"full_name" binding:"required"`
	DateOfBirth   string `json:"date_of_birth" binding:"required"`
	Gender        string `json:"gender" binding:"required"`
	Address       string `json:"address" binding:"required"`
	AadhaarNumber string `json:"aadhaar_number" binding:"required"`
	PANNumber     string `json:"pan_number"`
}

type VerifyDocumentRequest struct {
	DocumentID string `json:"document_id" binding:"required"`
	Status     string `json:"status" binding:"required"`
	Reason     string `json:"reason"`
}
