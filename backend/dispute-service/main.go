package main

import (
	"log"
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
	InitDB()

	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins:     corsOrigins(),
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Request-ID"},
		AllowCredentials: true,
	}))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "service": "dispute-service"})
	})

	r.POST("/api/v1/disputes/raise", RaiseDispute)
	r.GET("/api/v1/disputes/user/:user_id", GetDisputes)
	r.GET("/api/v1/disputes/:id", GetDisputeByID)
	r.PUT("/api/v1/disputes/resolve", ResolveDispute)
	r.GET("/api/v1/disputes", GetAllDisputes)

	log.Println("Dispute Service starting on port 8007...")
	log.Fatal(r.Run(":8007"))
}
