package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

// newRouter builds a minimal router for testing (no real DB).
func newRouter() *gin.Engine {
	r := gin.New()
	r.POST("/api/v1/payments/send", SendMoney)
	r.POST("/api/v1/wallet/add-money", AddMoney)
	return r
}

// ── Input validation tests (no DB needed — all fail before hitting DB) ───────

func TestSendMoney_MissingReceiverPhone(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"sender_user_id": "uuid-sender",
		"amount":         100,
		// receiver_phone intentionally missing
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/payments/send", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

func TestSendMoney_InvalidReceiverPhone(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"sender_user_id": "uuid-sender",
		"receiver_phone": "12345",  // only 5 digits
		"amount":         100,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/payments/send", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for short phone, got %d", w.Code)
	}
}

func TestSendMoney_AmountTooLow(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"sender_user_id": "uuid-sender",
		"receiver_phone": "9876543210",
		"amount":         0.5,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/payments/send", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for amount < 1, got %d", w.Code)
	}
}

func TestSendMoney_AmountTooHigh(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"sender_user_id": "uuid-sender",
		"receiver_phone": "9876543210",
		"amount":         200000,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/payments/send", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for amount > 100000, got %d", w.Code)
	}
}

func TestAddMoney_AmountTooLow(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"user_id": "uuid-user",
		"amount":  0,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/wallet/add-money", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for amount=0, got %d", w.Code)
	}
}

func TestAddMoney_AmountTooHigh(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"user_id": "uuid-user",
		"amount":  999999,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/wallet/add-money", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for amount > 100000, got %d", w.Code)
	}
}

func TestAddMoney_InvalidJSON(t *testing.T) {
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/wallet/add-money",
		bytes.NewBufferString("{not valid json}"))
	req.Header.Set("Content-Type", "application/json")
	newRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for invalid JSON, got %d", w.Code)
	}
}
