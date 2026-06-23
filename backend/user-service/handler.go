package main

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

func RegisterUser(c *gin.Context) {
	var req RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// Input validation
	if !isValidPhone(req.Phone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Phone must be exactly 10 digits"})
		return
	}
	if !isValidName(req.FullName) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Name must be 2–100 characters"})
		return
	}
	if !isValidEmail(req.Email) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid email format"})
		return
	}
	if !isValidPIN(req.Pin) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "PIN must be 4 to 6 digits"})
		return
	}
	if !isValidRole(req.Role) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Role must be customer, merchant, or agent"})
		return
	}

	// Duplicate phone check
	var existingID string
	err := DB.QueryRow(`SELECT id FROM users WHERE phone = $1`, req.Phone).Scan(&existingID)
	if err != sql.ErrNoRows {
		c.JSON(http.StatusConflict, gin.H{"error": "Phone number already registered"})
		return
	}

	// PIN hash karo
	hashedPin, err := bcrypt.GenerateFromPassword([]byte(req.Pin), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "PIN hashing failed",
		})
		return
	}

	// Role set karo — frontend se aaye to use karo, warna default 'customer'
	role := req.Role
	if role == "" {
		role = "customer"
	}

	// Database mein save karo
	user := User{
		ID:        uuid.New().String(),
		Phone:     req.Phone,
		Email:     req.Email,
		FullName:  req.FullName,
		Role:      role,
		PinHash:   string(hashedPin),
		KYCStatus: "pending",
		IsActive:  true,
	}

	query := `INSERT INTO users (id, phone, email, full_name, role, pin_hash, kyc_status, is_active)
			  VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`

	_, err = DB.Exec(query, user.ID, user.Phone, user.Email, user.FullName, user.Role, user.PinHash, user.KYCStatus, user.IsActive)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "User registration failed",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User registered successfully",
		"user_id": user.ID,
	})
}

func LoginUser(c *gin.Context) {
	var req LoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	if !isValidPhone(req.Phone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Phone must be exactly 10 digits"})
		return
	}
	if !isValidPIN(req.Pin) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "PIN must be 4 to 6 digits"})
		return
	}

	// Database se user dhundo
	var user User
	query := `SELECT id, phone, email, full_name, role, pin_hash, kyc_status, is_active FROM users WHERE phone = $1`
	err := DB.QueryRow(query, req.Phone).Scan(
		&user.ID, &user.Phone, &user.Email, &user.FullName, &user.Role,
		&user.PinHash, &user.KYCStatus, &user.IsActive,
	)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid phone or PIN",
		})
		return
	}

	// PIN verify karo
	err = bcrypt.CompareHashAndPassword([]byte(user.PinHash), []byte(req.Pin))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid phone or PIN",
		})
		return
	}

	// JWT access token (15 min)
	accessToken, err := GenerateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Token generation failed"})
		return
	}

	// Refresh token (30 days)
	refreshToken, err := GenerateRefreshToken(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Refresh token generation failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token":         accessToken,
		"refresh_token": refreshToken,
		"user":          user,
	})
}

func GetUser(c *gin.Context) {
	id := c.Param("id")

	var user User
	query := `SELECT id, phone, email, full_name, kyc_status, is_active FROM users WHERE id = $1`
	err := DB.QueryRow(query, id).Scan(
		&user.ID, &user.Phone, &user.Email,
		&user.FullName, &user.KYCStatus, &user.IsActive,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "User not found",
		})
		return
	}

	c.JSON(http.StatusOK, user)
}
