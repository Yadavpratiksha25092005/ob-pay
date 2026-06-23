package main

import "regexp"

var phoneRegex = regexp.MustCompile(`^\d{10}$`)

func isValidPhone(phone string) bool {
	return phoneRegex.MatchString(phone)
}
