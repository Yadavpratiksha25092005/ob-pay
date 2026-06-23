package main

import (
	"io"
	"net/http"
	"os"
	"github.com/gin-gonic/gin"
)

func getServiceURL(envKey, defaultURL string) string {
	if v := os.Getenv(envKey); v != "" {
		return v
	}
	return defaultURL
}

func proxyRequest(c *gin.Context, targetURL string) {
	url := targetURL + c.Request.URL.Path
	if c.Request.URL.RawQuery != "" {
		url += "?" + c.Request.URL.RawQuery
	}
	req, err := http.NewRequest(c.Request.Method, url, c.Request.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}
	for key, values := range c.Request.Header {
		for _, value := range values {
			req.Header.Add(key, value)
		}
	}
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Service unavailable"})
		return
	}
	defer resp.Body.Close()
	for key, values := range resp.Header {
		for _, value := range values {
			c.Header(key, value)
		}
	}
	c.Status(resp.StatusCode)
	io.Copy(c.Writer, resp.Body)
}

func UserServiceProxy(c *gin.Context) {
	proxyRequest(c, getServiceURL("USER_SERVICE_URL", "http://localhost:8001"))
}
func PaymentServiceProxy(c *gin.Context) {
	proxyRequest(c, getServiceURL("PAYMENT_SERVICE_URL", "http://localhost:8002"))
}
func TransactionServiceProxy(c *gin.Context) {
	proxyRequest(c, getServiceURL("TRANSACTION_SERVICE_URL", "http://localhost:8003"))
}
func NotificationServiceProxy(c *gin.Context) {
	proxyRequest(c, getServiceURL("NOTIFICATION_SERVICE_URL", "http://localhost:8004"))
}
func SettlementServiceProxy(c *gin.Context) {
	proxyRequest(c, getServiceURL("SETTLEMENT_SERVICE_URL", "http://localhost:8005"))
}
