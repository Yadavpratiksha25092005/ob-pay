package main

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// ── Token generation & validation ────────────────────────────────────────────

func TestGenerateToken_ValidClaims(t *testing.T) {
	token, err := GenerateToken("user-123", "customer")
	if err != nil {
		t.Fatalf("GenerateToken failed: %v", err)
	}
	if token == "" {
		t.Fatal("expected non-empty token")
	}
}

func TestValidateToken_RoundTrip(t *testing.T) {
	userID := "user-abc"
	role := "merchant"

	raw, err := GenerateToken(userID, role)
	if err != nil {
		t.Fatalf("GenerateToken: %v", err)
	}

	claims, err := ValidateToken(raw)
	if err != nil {
		t.Fatalf("ValidateToken: %v", err)
	}
	if claims.UserID != userID {
		t.Errorf("UserID: got %q, want %q", claims.UserID, userID)
	}
	if claims.Role != role {
		t.Errorf("Role: got %q, want %q", claims.Role, role)
	}
}

func TestValidateToken_ExpiredToken(t *testing.T) {
	// Build a token that expired 1 hour ago
	claims := Claims{
		UserID: "expired-user",
		Role:   "customer",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(-1 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now().Add(-2 * time.Hour)),
		},
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, _ := tok.SignedString(jwtSecret)

	_, err := ValidateToken(signed)
	if err == nil {
		t.Error("expected error for expired token, got nil")
	}
}

func TestValidateToken_TamperedSignature(t *testing.T) {
	raw, _ := GenerateToken("user-x", "customer")
	tampered := raw + "tampered"
	_, err := ValidateToken(tampered)
	if err == nil {
		t.Error("expected error for tampered token, got nil")
	}
}

func TestValidateToken_WrongSecret(t *testing.T) {
	// Token signed with a different secret
	claims := Claims{
		UserID: "user-y",
		Role:   "customer",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(15 * time.Minute)),
		},
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, _ := tok.SignedString([]byte("wrong-secret"))

	_, err := ValidateToken(signed)
	if err == nil {
		t.Error("expected error for wrong-secret token, got nil")
	}
}

func TestTokenTTL_AccessToken(t *testing.T) {
	raw, _ := GenerateToken("u1", "customer")
	claims, _ := ValidateToken(raw)
	ttl := time.Until(claims.ExpiresAt.Time)
	// Should be ~15 minutes — allow ±5 seconds drift
	if ttl > accessTokenTTL+5*time.Second || ttl < accessTokenTTL-5*time.Second {
		t.Errorf("access token TTL = %v, want ~%v", ttl, accessTokenTTL)
	}
}

// ── Hash helper ───────────────────────────────────────────────────────────────

func TestHashToken_Deterministic(t *testing.T) {
	h1 := hashToken("my-token")
	h2 := hashToken("my-token")
	if h1 != h2 {
		t.Error("hashToken must be deterministic")
	}
}

func TestHashToken_DifferentInputs(t *testing.T) {
	h1 := hashToken("token-a")
	h2 := hashToken("token-b")
	if h1 == h2 {
		t.Error("different inputs must produce different hashes")
	}
}
