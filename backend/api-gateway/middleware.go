package main

import (
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

var jwtSecret = func() []byte {
	s := os.Getenv("JWT_SECRET")
	if s == "" {
		s = "obpay-secret-key-change-in-production"
	}
	return []byte(s)
}()

type Claims struct {
	UserID string `json:"user_id"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

// JWT Authentication middleware
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Authorization header required",
			})
			c.Abort()
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")

		token, err := jwt.ParseWithClaims(tokenStr, &Claims{},
			func(token *jwt.Token) (interface{}, error) {
				return jwtSecret, nil
			})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		claims, ok := token.Claims.(*Claims)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid token claims",
			})
			c.Abort()
			return
		}

		c.Set("user_id", claims.UserID)
		c.Set("role", claims.Role)
		c.Next()
	}
}

// Admin-only middleware — requires valid JWT with role=admin
func AdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")

		token, err := jwt.ParseWithClaims(tokenStr, &Claims{},
			func(token *jwt.Token) (interface{}, error) {
				return jwtSecret, nil
			})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		claims, ok := token.Claims.(*Claims)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			c.Abort()
			return
		}

		if claims.Role != "admin" {
			c.JSON(http.StatusForbidden, gin.H{"error": "Admin access required"})
			c.Abort()
			return
		}

		c.Set("user_id", claims.UserID)
		c.Set("role", claims.Role)
		c.Next()
	}
}

// Rate Limiting middleware
func RateLimitMiddleware() gin.HandlerFunc {
	requests := make(map[string][]time.Time)

	return func(c *gin.Context) {
		ip := c.ClientIP()
		now := time.Now()

		// Clean old requests (older than 1 minute)
		if times, exists := requests[ip]; exists {
			var recent []time.Time
			for _, t := range times {
				if now.Sub(t) < time.Minute {
					recent = append(recent, t)
				}
			}
			requests[ip] = recent
		}

		// Check rate limit (100 requests per minute)
		if len(requests[ip]) >= 100 {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error": "Rate limit exceeded. Try again later.",
			})
			c.Abort()
			return
		}

		requests[ip] = append(requests[ip], now)
		c.Next()
	}
}

// Logger middleware
func LoggerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		duration := time.Since(start)

		gin.DefaultWriter.Write([]byte(
			"[GATEWAY] " +
				c.Request.Method + " " +
				c.Request.URL.Path +
				" | Status: " + http.StatusText(c.Writer.Status()) +
				" | Duration: " + duration.String() + "\n",
		))
	}
}
