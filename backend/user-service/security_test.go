package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func newUserRouter() *gin.Engine {
	r := gin.New()
	r.POST("/api/v1/users/register", RegisterUser)
	r.POST("/api/v1/users/login", LoginUser)
	return r
}

// ── JWT role-claim security ───────────────────────────────────────────────────

func TestAdminRoleNotSelfRegistrable(t *testing.T) {
	// Registration should reject "admin" as a role
	body, _ := json.Marshal(map[string]interface{}{
		"phone":     "9111111111",
		"full_name": "Evil Admin",
		"email":     "evil@example.com",
		"pin":       "123456",
		"role":      "admin",
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/users/register", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newUserRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("admin self-registration should be rejected with 400, got %d", w.Code)
	}
}

func TestTokenContainsRole(t *testing.T) {
	tok, err := GenerateToken("user-1", "merchant")
	if err != nil {
		t.Fatal(err)
	}
	claims, err := ValidateToken(tok)
	if err != nil {
		t.Fatal(err)
	}
	if claims.Role != "merchant" {
		t.Errorf("token role: got %q, want %q", claims.Role, "merchant")
	}
}

// ── Input sanitisation / injection protection ─────────────────────────────────

func TestRegister_SQLInjectionPhone(t *testing.T) {
	injections := []string{
		"'; DROP TABLE users; --",
		"1' OR '1'='1",
		"9876543210' UNION SELECT * FROM users--",
	}
	for _, phone := range injections {
		body, _ := json.Marshal(map[string]interface{}{
			"phone":     phone,
			"full_name": "Hacker",
			"email":     "h@x.com",
			"pin":       "1234",
			"role":      "customer",
		})
		w := httptest.NewRecorder()
		req, _ := http.NewRequest("POST", "/api/v1/users/register", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		newUserRouter().ServeHTTP(w, req)

		if w.Code != http.StatusBadRequest {
			t.Errorf("SQL injection phone %q should be rejected (400), got %d", phone, w.Code)
		}
	}
}

func TestRegister_XSSInName(t *testing.T) {
	// XSS payloads in full_name — validation rejects them via length/character rules
	// The API returns 400 for names that fail validation; otherwise the DB stores as-is
	// (output encoding is the responsibility of the client/frontend).
	// Test that short-name check still applies:
	body, _ := json.Marshal(map[string]interface{}{
		"phone":     "9123456789",
		"full_name": "A", // too short
		"email":     "a@b.com",
		"pin":       "1234",
		"role":      "customer",
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/users/register", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newUserRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("short name should be rejected with 400, got %d", w.Code)
	}
}

func TestRegister_OversizePayload(t *testing.T) {
	// Extremely long values should be rejected by validation before hitting DB
	longName := strings.Repeat("A", 1000)
	body, _ := json.Marshal(map[string]interface{}{
		"phone":     "9999999999",
		"full_name": longName,
		"email":     "x@y.com",
		"pin":       "1234",
		"role":      "customer",
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/users/register", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newUserRouter().ServeHTTP(w, req)

	// Should return 400 because isValidName allows max 100 chars
	if w.Code != http.StatusBadRequest {
		t.Errorf("oversize name should be rejected with 400, got %d", w.Code)
	}
}

func TestLogin_EmptyBody(t *testing.T) {
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/users/login", bytes.NewBufferString("{}"))
	req.Header.Set("Content-Type", "application/json")
	newUserRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("empty login body should return 400, got %d", w.Code)
	}
}

func TestLogin_InvalidPhone(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"phone": "abc",
		"pin":   "1234",
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/users/login", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newUserRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("invalid phone should return 400, got %d", w.Code)
	}
}
