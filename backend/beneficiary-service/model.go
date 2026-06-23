package main

import "time"

type Beneficiary struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Name      string    `json:"name"`
	Phone     string    `json:"phone"`
	Nickname  string    `json:"nickname"`
	CreatedAt time.Time `json:"created_at"`
}

type AddBeneficiaryRequest struct {
	UserID   string `json:"user_id"  binding:"required"`
	Name     string `json:"name"     binding:"required"`
	Phone    string `json:"phone"    binding:"required"`
	Nickname string `json:"nickname"`
}

type UpdateNicknameRequest struct {
	Nickname string `json:"nickname" binding:"required"`
}
