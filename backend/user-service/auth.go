package main

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var jwtSecret = func() []byte {
	s := os.Getenv("JWT_SECRET")
	if s == "" {
		s = "obpay-secret-key-change-in-production"
	}
	return []byte(s)
}()

const (
	accessTokenTTL  = 15 * time.Minute
	refreshTokenTTL = 30 * 24 * time.Hour
)

type Claims struct {
	UserID string `json:"user_id"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

// GenerateToken creates a short-lived JWT access token (15 min).
func GenerateToken(userID, role string) (string, error) {
	claims := Claims{
		UserID: userID,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(accessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// ValidateToken parses and validates a JWT access token.
func ValidateToken(tokenStr string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, jwt.ErrTokenInvalidClaims
	}
	return claims, nil
}

// GenerateRefreshToken creates a cryptographically random refresh token,
// stores its SHA-256 hash in the DB, and returns the raw token to the caller.
func GenerateRefreshToken(userID string) (string, error) {
	raw := make([]byte, 32)
	if _, err := rand.Read(raw); err != nil {
		return "", err
	}
	tokenStr := base64.URLEncoding.EncodeToString(raw)
	hash := hashToken(tokenStr)
	expiresAt := time.Now().Add(refreshTokenTTL)

	_, err := DB.Exec(`
		INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
		VALUES ($1, $2, $3)
	`, userID, hash, expiresAt)
	if err != nil {
		return "", err
	}
	return tokenStr, nil
}

// ValidateRefreshToken looks up the hashed token in the DB.
// Returns (userID, error). Deletes the token so it can only be used once (rotation).
func ValidateRefreshToken(tokenStr string) (string, error) {
	hash := hashToken(tokenStr)
	var userID string
	var expiresAt time.Time
	var revokedAt *time.Time

	err := DB.QueryRow(`
		SELECT user_id, expires_at, revoked_at
		FROM refresh_tokens
		WHERE token_hash = $1
	`, hash).Scan(&userID, &expiresAt, &revokedAt)
	if err != nil {
		return "", err
	}
	if revokedAt != nil {
		return "", jwt.ErrTokenInvalidClaims
	}
	if time.Now().After(expiresAt) {
		return "", jwt.ErrTokenExpired
	}

	// Rotate: delete old token — a new one will be issued
	DB.Exec(`DELETE FROM refresh_tokens WHERE token_hash = $1`, hash)
	return userID, nil
}

// RevokeRefreshToken marks a token as revoked (soft-delete for logout).
func RevokeRefreshToken(tokenStr string) {
	hash := hashToken(tokenStr)
	DB.Exec(`UPDATE refresh_tokens SET revoked_at=NOW() WHERE token_hash=$1`, hash)
}

// RevokeAllRefreshTokens revokes all tokens for a user (logout-all).
func RevokeAllRefreshTokens(userID string) {
	DB.Exec(`UPDATE refresh_tokens SET revoked_at=NOW() WHERE user_id=$1 AND revoked_at IS NULL`, userID)
}

func hashToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return hex.EncodeToString(h[:])
}
