package main

import "time"

type User struct {
	ID        string    `json:"id"`
	Phone     string    `json:"phone"`
	Email     string    `json:"email"`
	FullName  string    `json:"full_name"`
	Role      string    `json:"role"`
	PinHash   string    `json:"-"`
	KYCStatus string    `json:"kyc_status"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type RegisterRequest struct {
	Phone        string `json:"phone" binding:"required"`
	Email        string `json:"email"`
	FullName     string `json:"full_name" binding:"required"`
	Pin          string `json:"pin" binding:"required"`
	Role         string `json:"role"`
	BusinessName string `json:"business_name"`
	Area         string `json:"area"`
}

type LoginRequest struct {
	Phone string `json:"phone" binding:"required"`
	Pin   string `json:"pin" binding:"required"`
}

type LoginResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}
