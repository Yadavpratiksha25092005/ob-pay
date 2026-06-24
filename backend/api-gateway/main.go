package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

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
	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins:     corsOrigins(),
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Request-ID"},
		AllowCredentials: true,
	}))

	r.Use(LoggerMiddleware())
	r.Use(RateLimitMiddleware())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"service": "api-gateway",
			"version": "1.0.0",
		})
	})

	r.GET("/services/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"user-service":         getServiceURL("USER_SERVICE_URL", "http://localhost:8001") + "/health",
			"payment-service":      getServiceURL("PAYMENT_SERVICE_URL", "http://localhost:8002") + "/health",
			"transaction-service":  getServiceURL("TRANSACTION_SERVICE_URL", "http://localhost:8003") + "/health",
			"notification-service": getServiceURL("NOTIFICATION_SERVICE_URL", "http://localhost:8004") + "/health",
			"settlement-service":   getServiceURL("SETTLEMENT_SERVICE_URL", "http://localhost:8005") + "/health",
			"rewards-service":      getServiceURL("REWARDS_SERVICE_URL", "http://localhost:8012") + "/health",
			"analytics-service":    getServiceURL("ANALYTICS_SERVICE_URL", "http://localhost:8013") + "/health",
			"beneficiary-service":  getServiceURL("BENEFICIARY_SERVICE_URL", "http://localhost:8014") + "/health",
		})
	})

	// Admin routes
	adminGroup := r.Group("/api/v1/admin")
	adminGroup.Use(AdminMiddleware())
	{
		adminGroup.GET("/users", UserServiceProxy)
		adminGroup.GET("/stats", UserServiceProxy)
		adminGroup.GET("/transactions", PaymentServiceProxy)
	}

	// Public routes
	public := r.Group("/api/v1")
	{
		// User routes
		public.POST("/users/register", UserServiceProxy)
		public.POST("/users/login", UserServiceProxy)
		public.POST("/users/refresh", UserServiceProxy)
		public.POST("/users/logout", UserServiceProxy)
		public.POST("/users/logout-all", UserServiceProxy)
		public.GET("/users/:id", UserServiceProxy)
		public.GET("/users/phone/:phone", UserServiceProxy)
		public.POST("/users/fcm-token", UserServiceProxy)

		// Payment routes
		public.POST("/wallet/create", PaymentServiceProxy)
		public.GET("/wallet/:user_id", PaymentServiceProxy)
		public.POST("/payments/send", PaymentServiceProxy)
		public.GET("/payments/history/:user_id", PaymentServiceProxy)
		public.POST("/wallet/add-money", PaymentServiceProxy)

		// Notification routes
		public.POST("/notifications/send", NotificationServiceProxy)
		public.POST("/notifications/payment", NotificationServiceProxy)
		public.GET("/notifications/user/:user_id", NotificationServiceProxy)
		public.GET("/notifications/user/:user_id/unread", NotificationServiceProxy)
		public.PUT("/notifications/item/:id/read", NotificationServiceProxy)
		public.PUT("/notifications/user/:user_id/read-all", NotificationServiceProxy)

		// Transaction routes
		public.POST("/transactions", TransactionServiceProxy)
		public.GET("/transactions", TransactionServiceProxy)
		public.GET("/transactions/summary/:user_id", TransactionServiceProxy)

		// Settlement routes
		public.POST("/settlements/request", SettlementServiceProxy)
		public.GET("/settlements/:merchant_id", SettlementServiceProxy)
		public.PUT("/settlements/:id/process", SettlementServiceProxy)

		// Rewards routes
		public.GET("/rewards/:user_id", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("REWARDS_SERVICE_URL", "http://localhost:8012")+"/api/v1/rewards/"+c.Param("user_id"))
		})
		public.POST("/rewards/event", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("REWARDS_SERVICE_URL", "http://localhost:8012")+"/api/v1/rewards/event")
		})
		public.POST("/rewards/add", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("REWARDS_SERVICE_URL", "http://localhost:8012")+"/api/v1/rewards/add")
		})
		public.POST("/rewards/redeem", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("REWARDS_SERVICE_URL", "http://localhost:8012")+"/api/v1/rewards/redeem")
		})
		public.GET("/offers", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("REWARDS_SERVICE_URL", "http://localhost:8012")+"/api/v1/offers")
		})

		// Analytics routes
		public.GET("/analytics/:user_id", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("ANALYTICS_SERVICE_URL", "http://localhost:8013")+"/api/v1/analytics/"+c.Param("user_id"))
		})
		public.GET("/analytics/:user_id/summary", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("ANALYTICS_SERVICE_URL", "http://localhost:8013")+"/api/v1/analytics/"+c.Param("user_id")+"/summary")
		})
		public.GET("/analytics/admin/overview", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("ANALYTICS_SERVICE_URL", "http://localhost:8013")+"/api/v1/analytics/admin/overview")
		})

		// KYC routes
		public.POST("/kyc/submit", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("KYC_SERVICE_URL", "http://localhost:8006")+"/api/v1/kyc/submit")
		})
		public.GET("/kyc/status/:user_id", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("KYC_SERVICE_URL", "http://localhost:8006")+"/api/v1/kyc/status/"+c.Param("user_id"))
		})
		public.PUT("/kyc/verify", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("KYC_SERVICE_URL", "http://localhost:8006")+"/api/v1/kyc/verify")
		})

		// Beneficiary routes
		public.POST("/beneficiaries", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("BENEFICIARY_SERVICE_URL", "http://localhost:8014")+"/api/v1/beneficiaries")
		})
		public.GET("/beneficiaries/:user_id", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("BENEFICIARY_SERVICE_URL", "http://localhost:8014")+"/api/v1/beneficiaries/"+c.Param("user_id"))
		})
		public.PUT("/beneficiaries/:id", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("BENEFICIARY_SERVICE_URL", "http://localhost:8014")+"/api/v1/beneficiaries/"+c.Param("id"))
		})
		public.DELETE("/beneficiaries/:id", func(c *gin.Context) {
			proxyRequest(c, getServiceURL("BENEFICIARY_SERVICE_URL", "http://localhost:8014")+"/api/v1/beneficiaries/"+c.Param("id"))
		})
	}

	log.Println("API Gateway starting on port 8000...")
	log.Fatal(r.Run(":8000"))
}
