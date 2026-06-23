package main

import (
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

const (
	userServiceURL         = "http://localhost:8001"
	paymentServiceURL      = "http://localhost:8002"
	transactionServiceURL  = "http://localhost:8003"
	notificationServiceURL = "http://localhost:8004"
	settlementServiceURL   = "http://localhost:8005"
)

func proxyRequest(c *gin.Context, targetURL string) {
	// Build target URL
	url := targetURL + c.Request.URL.Path
	if c.Request.URL.RawQuery != "" {
		url += "?" + c.Request.URL.RawQuery
	}

	// Create new request
	req, err := http.NewRequest(c.Request.Method, url, c.Request.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to create request",
		})
		return
	}

	// Copy headers
	for key, values := range c.Request.Header {
		for _, value := range values {
			req.Header.Add(key, value)
		}
	}

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"error": "Service unavailable",
		})
		return
	}
	defer resp.Body.Close()

	// Copy response headers
	for key, values := range resp.Header {
		for _, value := range values {
			c.Header(key, value)
		}
	}

	// Copy response body
	c.Status(resp.StatusCode)
	io.Copy(c.Writer, resp.Body)
}

// User Service proxy
func UserServiceProxy(c *gin.Context) {
	proxyRequest(c, userServiceURL)
}

// Payment Service proxy
func PaymentServiceProxy(c *gin.Context) {
	proxyRequest(c, paymentServiceURL)
}

// Transaction Service proxy
func TransactionServiceProxy(c *gin.Context) {
	proxyRequest(c, transactionServiceURL)
}

// Notification Service proxy
func NotificationServiceProxy(c *gin.Context) {
	proxyRequest(c, notificationServiceURL)
}

// Settlement Service proxy
func SettlementServiceProxy(c *gin.Context) {
	proxyRequest(c, settlementServiceURL)
}
