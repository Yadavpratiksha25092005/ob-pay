package main

import (
	"regexp"
	"strings"
)

var (
	phoneRegex = regexp.MustCompile(`^\d{10}$`)
	pinRegex   = regexp.MustCompile(`^\d{4,6}$`)
	emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	validRoles = map[string]bool{"customer": true, "merchant": true, "agent": true}
)

func isValidPhone(phone string) bool {
	return phoneRegex.MatchString(phone)
}

func isValidPIN(pin string) bool {
	return pinRegex.MatchString(pin)
}

func isValidEmail(email string) bool {
	if email == "" {
		return true
	}
	return emailRegex.MatchString(email)
}

func isValidName(name string) bool {
	name = strings.TrimSpace(name)
	return len(name) >= 2 && len(name) <= 100
}

func isValidRole(role string) bool {
	if role == "" {
		return true
	}
	return validRoles[role]
}
