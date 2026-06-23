package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func requireAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}
		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		claims, err := ValidateToken(tokenStr)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
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

func corsOrigins() []string {
	if v := os.Getenv("ALLOWED_ORIGINS"); v != "" {
		var out []string
		for _, o := range strings.Split(v, ",") {
			if s := strings.TrimSpace(o); s != "" {
				out = append(out, s)
			}
		}
		return out
	}
	if os.Getenv("APP_ENV") == "production" {
		return []string{"https://obpay.in", "https://admin.obpay.in"}
	}
	return []string{"http://localhost:3000", "http://localhost:8080", "http://localhost:8081"}
}

func main() {
	InitDB()

	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins:     corsOrigins(),
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Request-ID"},
		AllowCredentials: true,
	}))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"service": "user-service",
		})
	})

	r.POST("/api/v1/users/register", RegisterUser)
	r.POST("/api/v1/users/login", LoginUser)

	// Refresh token — exchange a valid refresh token for a new access+refresh pair
	r.POST("/api/v1/users/refresh", func(c *gin.Context) {
		var req struct {
			RefreshToken string `json:"refresh_token"`
		}
		if err := c.ShouldBindJSON(&req); err != nil || req.RefreshToken == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "refresh_token required"})
			return
		}
		userID, err := ValidateRefreshToken(req.RefreshToken)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired refresh token"})
			return
		}
		// Fetch user role for the new access token
		var role string
		if err := DB.QueryRow(`SELECT role FROM users WHERE id=$1`, userID).Scan(&role); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
			return
		}
		accessToken, err := GenerateToken(userID, role)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Token generation failed"})
			return
		}
		newRefresh, err := GenerateRefreshToken(userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Refresh token generation failed"})
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"token":         accessToken,
			"refresh_token": newRefresh,
		})
	})

	// Logout — revoke a single refresh token
	r.POST("/api/v1/users/logout", func(c *gin.Context) {
		var req struct {
			RefreshToken string `json:"refresh_token"`
		}
		if err := c.ShouldBindJSON(&req); err != nil || req.RefreshToken == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "refresh_token required"})
			return
		}
		RevokeRefreshToken(req.RefreshToken)
		c.JSON(http.StatusOK, gin.H{"message": "Logged out successfully"})
	})

	// Logout-all — revoke all refresh tokens for the authenticated user
	r.POST("/api/v1/users/logout-all", func(c *gin.Context) {
		var req struct {
			UserID string `json:"user_id"`
		}
		if err := c.ShouldBindJSON(&req); err != nil || req.UserID == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "user_id required"})
			return
		}
		RevokeAllRefreshTokens(req.UserID)
		c.JSON(http.StatusOK, gin.H{"message": "All sessions revoked"})
	})

	r.GET("/api/v1/users/:id", GetUser)
	r.GET("/api/v1/users/phone/:phone", func(c *gin.Context) {
		phone := c.Param("phone")
		var id, fullName, phoneNum string
		err := DB.QueryRow(
			"SELECT id, full_name, phone FROM users WHERE phone = $1",
			phone,
		).Scan(&id, &fullName, &phoneNum)
		if err != nil {
			c.JSON(404, gin.H{"error": "User not found"})
			return
		}
		c.JSON(200, gin.H{
			"id":        id,
			"full_name": fullName,
			"phone":     phoneNum,
		})
	})

	r.POST("/api/v1/users/fcm-token", func(c *gin.Context) {
		var req struct {
			UserID   string `json:"user_id"`
			FCMToken string `json:"fcm_token"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(400, gin.H{"error": err.Error()})
			return
		}
		_, err := DB.Exec(
			"UPDATE users SET fcm_token = $1 WHERE id = $2",
			req.FCMToken, req.UserID,
		)
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to save FCM token"})
			return
		}
		c.JSON(200, gin.H{"message": "FCM token saved"})
	})

	// Admin routes (JWT-protected, role=admin required)
	admin := r.Group("/api/v1/admin")
	admin.Use(requireAdmin())
	{
		admin.GET("/users", func(c *gin.Context) {
			rows, err := DB.Query(`SELECT id, full_name, phone, email, is_active, role, created_at FROM users ORDER BY created_at DESC`)
			if err != nil {
				c.JSON(500, gin.H{"error": "Failed to get users"})
				return
			}
			defer rows.Close()
			var users []gin.H
			for rows.Next() {
				var id, fullName, phone, email, role string
				var isActive bool
				var createdAt interface{}
				rows.Scan(&id, &fullName, &phone, &email, &isActive, &role, &createdAt)
				users = append(users, gin.H{
					"id": id, "full_name": fullName,
					"phone": phone, "email": email,
					"is_active": isActive, "role": role,
					"created_at": createdAt,
				})
			}
			c.JSON(200, gin.H{"users": users, "count": len(users)})
		})

		admin.GET("/stats", func(c *gin.Context) {
			var totalUsers, totalMerchants, totalAgents int
			DB.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&totalUsers)
			DB.QueryRow(`SELECT COUNT(*) FROM users WHERE role='merchant'`).Scan(&totalMerchants)
			DB.QueryRow(`SELECT COUNT(*) FROM users WHERE role='agent'`).Scan(&totalAgents)
			c.JSON(200, gin.H{
				"total_users":     totalUsers,
				"total_merchants": totalMerchants,
				"total_agents":    totalAgents,
			})
		})
	}

	// Admin setup: promote a user to admin role (one-time, protected by secret key)
	r.POST("/api/v1/admin/setup", func(c *gin.Context) {
		var req struct {
			Phone  string `json:"phone"`
			Secret string `json:"secret"`
		}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(400, gin.H{"error": err.Error()})
			return
		}
		setupSecret := os.Getenv("ADMIN_SETUP_SECRET")
		if setupSecret == "" {
			setupSecret = "obpay-admin-setup-2024"
		}
		if req.Secret != setupSecret {
			c.JSON(http.StatusForbidden, gin.H{"error": "Invalid setup secret"})
			return
		}
		res, err := DB.Exec(`UPDATE users SET role='admin' WHERE phone=$1`, req.Phone)
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to update role"})
			return
		}
		n, _ := res.RowsAffected()
		if n == 0 {
			c.JSON(404, gin.H{"error": "User not found"})
			return
		}
		c.JSON(200, gin.H{"message": "User promoted to admin", "phone": req.Phone})
	})

	log.Println("User Service starting on port 8001...")
	log.Fatal(r.Run(":8001"))
}
