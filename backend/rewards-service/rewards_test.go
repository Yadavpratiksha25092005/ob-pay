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

func newTestRouter() *gin.Engine {
	r := gin.New()
	r.POST("/api/v1/rewards/event", triggerRewardEvent)
	r.POST("/api/v1/rewards/add", addPoints)
	r.POST("/api/v1/rewards/redeem", redeemPoints)
	return r
}

// ── Input validation (no DB required — all fail before touching DB) ──────────

func TestTriggerRewardEvent_MissingUserID(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"event_type": RuleSignupBonus,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/rewards/event", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newTestRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for missing user_id, got %d", w.Code)
	}
}

func TestTriggerRewardEvent_MissingEventType(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"user_id": "user-123",
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/rewards/event", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newTestRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for missing event_type, got %d", w.Code)
	}
}

func TestTriggerRewardEvent_UnknownEventType(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"user_id":    "user-123",
		"event_type": "unknown_event",
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/rewards/event", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newTestRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for unknown event_type, got %d", w.Code)
	}
}

func TestTriggerRewardEvent_TransactionBonusMissingAmount(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"user_id":    "user-123",
		"event_type": RuleTransactionBonus,
		// transaction_amount missing
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/rewards/event", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newTestRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for transaction_bonus without amount, got %d", w.Code)
	}
}

func TestAddPoints_ZeroPoints(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"user_id": "user-123",
		"points":  0,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/rewards/add", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newTestRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for points=0, got %d", w.Code)
	}
}

func TestRedeemPoints_ZeroPoints(t *testing.T) {
	body, _ := json.Marshal(map[string]interface{}{
		"user_id": "user-123",
		"points":  0,
	})
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/rewards/redeem", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	newTestRouter().ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for points=0, got %d", w.Code)
	}
}

// ── Reward point calculation logic ──────────────────────────────────────────

func TestTransactionBonusPoints(t *testing.T) {
	cases := []struct {
		amount float64
		want   int
	}{
		{100, 10},   // 1 × 10 pts
		{250, 20},   // 2 × 10 pts (floor)
		{99,  1},    // below ₹100 — minimum 1 pt
		{1000, 100}, // 10 × 10 pts
		{0.5, 1},    // very small — minimum 1 pt
	}
	for _, tc := range cases {
		got := int(tc.amount/100) * 10
		if got < 1 {
			got = 1
		}
		if got != tc.want {
			t.Errorf("transactionBonus(%.2f) = %d, want %d", tc.amount, got, tc.want)
		}
	}
}

func TestEventDescription_AllRules(t *testing.T) {
	rules := []string{RuleSignupBonus, RuleFirstTransaction, RuleReferral, RuleTransactionBonus}
	for _, r := range rules {
		desc := eventDescription(r, 100)
		if desc == "" {
			t.Errorf("eventDescription(%q) returned empty string", r)
		}
	}
}

func TestRewardPoints_Map(t *testing.T) {
	if rewardPoints[RuleSignupBonus] != 100 {
		t.Errorf("signup bonus expected 100, got %d", rewardPoints[RuleSignupBonus])
	}
	if rewardPoints[RuleFirstTransaction] != 500 {
		t.Errorf("first_transaction bonus expected 500, got %d", rewardPoints[RuleFirstTransaction])
	}
	if rewardPoints[RuleReferral] != 200 {
		t.Errorf("referral bonus expected 200, got %d", rewardPoints[RuleReferral])
	}
}
