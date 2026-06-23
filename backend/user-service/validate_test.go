package main

import "testing"

func TestIsValidPhone(t *testing.T) {
	cases := []struct {
		input string
		want  bool
	}{
		{"9876543210", true},
		{"1234567890", true},
		{"98765432",   false}, // 8 digits
		{"98765432100", false}, // 11 digits
		{"98765432ab", false}, // non-numeric
		{"",           false},
		{"+919876543210", false}, // E.164 format rejected
	}
	for _, tc := range cases {
		got := isValidPhone(tc.input)
		if got != tc.want {
			t.Errorf("isValidPhone(%q) = %v, want %v", tc.input, got, tc.want)
		}
	}
}

func TestIsValidPIN(t *testing.T) {
	cases := []struct {
		input string
		want  bool
	}{
		{"1234",   true},
		{"123456", true},
		{"12345",  true},
		{"123",    false}, // too short
		{"1234567", false}, // too long
		{"12ab",   false},
		{"",       false},
	}
	for _, tc := range cases {
		got := isValidPIN(tc.input)
		if got != tc.want {
			t.Errorf("isValidPIN(%q) = %v, want %v", tc.input, got, tc.want)
		}
	}
}

func TestIsValidEmail(t *testing.T) {
	cases := []struct {
		input string
		want  bool
	}{
		{"user@example.com",      true},
		{"user+tag@example.co.in", true},
		{"",                      false},
		{"not-an-email",          false},
		{"@example.com",          false},
		{"user@",                 false},
	}
	for _, tc := range cases {
		got := isValidEmail(tc.input)
		if got != tc.want {
			t.Errorf("isValidEmail(%q) = %v, want %v", tc.input, got, tc.want)
		}
	}
}

func TestIsValidRole(t *testing.T) {
	cases := []struct {
		input string
		want  bool
	}{
		{"customer", true},
		{"merchant", true},
		{"agent",    true},
		{"admin",    false}, // admin cannot self-register
		{"",         false},
		{"superuser", false},
	}
	for _, tc := range cases {
		got := isValidRole(tc.input)
		if got != tc.want {
			t.Errorf("isValidRole(%q) = %v, want %v", tc.input, got, tc.want)
		}
	}
}

func TestIsValidName(t *testing.T) {
	cases := []struct {
		input string
		want  bool
	}{
		{"Rahul Sharma", true},
		{"AB",           true},  // 2 chars minimum
		{"A",            false}, // 1 char
		{"",             false},
	}
	for _, tc := range cases {
		got := isValidName(tc.input)
		if got != tc.want {
			t.Errorf("isValidName(%q) = %v, want %v", tc.input, got, tc.want)
		}
	}
}
