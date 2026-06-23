package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"google.golang.org/api/option"
)

var fcmClient *messaging.Client

func InitFCM() {
	credFile := os.Getenv("FIREBASE_CREDENTIALS_FILE")
	if credFile == "" {
		credFile = "serviceAccountKey.json"
	}
	opt := option.WithCredentialsFile(credFile)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Println("Firebase init error:", err)
		return
	}
	fcmClient, err = app.Messaging(context.Background())
	if err != nil {
		log.Println("FCM client error:", err)
		return
	}
	log.Println("✅ FCM initialized successfully")
}

func sendFCMToUser(userID, title, body string) {
	if fcmClient == nil {
		log.Println("FCM client not initialized")
		return
	}

	// Get FCM token from DB
	var fcmToken string
	err := DB.QueryRow(`SELECT fcm_token FROM users WHERE id = $1`, userID).Scan(&fcmToken)
	if err != nil || fcmToken == "" {
		log.Println("FCM token not found for user:", userID)
		return
	}

	message := &messaging.Message{
		Token: fcmToken,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				Sound:     "default",
				ChannelID: "ob_pay_channel",
			},
		},
	}

	response, err := fcmClient.Send(context.Background(), message)
	if err != nil {
		log.Println("FCM send error:", err)
		return
	}
	log.Println("FCM notification sent:", response)
}

func SendNotification(c *gin.Context) {
	var req SendNotificationRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	id := uuid.New().String()
	query := `INSERT INTO notifications 
		(id, user_id, type, category, title, message, status)
		VALUES ($1,$2,$3,$4,$5,$6,$7)`

	_, err := DB.Exec(query,
		id, req.UserID, req.Type, req.Category,
		req.Title, req.Message, "sent",
	)
	if err != nil {
		log.Println("Send notification error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Notification failed"})
		return
	}

	// FCM push bhejo
	go sendFCMToUser(req.UserID, req.Title, req.Message)

	log.Printf("Notification sent to user %s: %s", req.UserID, req.Title)

	c.JSON(http.StatusCreated, gin.H{
		"message":         "Notification sent successfully",
		"notification_id": id,
	})
}

func SendPaymentNotification(c *gin.Context) {
	var req PaymentNotification

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var title, message string
	if req.Type == "sent" {
		title = "Payment Sent Successfully ✅"
		message = fmt.Sprintf("₹%.2f sent to %s successfully!", req.Amount, req.ReceiverName)
	} else {
		title = "Payment Received 💰"
		message = fmt.Sprintf("₹%.2f received from %s!", req.Amount, req.SenderName)
	}

	id := uuid.New().String()
	query := `INSERT INTO notifications
		(id, user_id, type, category, title, message, status)
		VALUES ($1,$2,$3,$4,$5,$6,$7)`

	_, err := DB.Exec(query,
		id, req.UserID, "push", "payment",
		title, message, "sent",
	)
	if err != nil {
		log.Println("Payment notification error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Notification failed"})
		return
	}

	// FCM push bhejo
	go sendFCMToUser(req.UserID, title, message)

	log.Printf("Payment notification → User: %s | %s | ₹%.2f",
		req.UserID, req.Type, req.Amount)

	c.JSON(http.StatusCreated, gin.H{
		"message":         "Payment notification sent",
		"notification_id": id,
		"title":           title,
	})
}

func GetNotifications(c *gin.Context) {
	userID := c.Param("user_id")

	rows, err := DB.Query(`
		SELECT id, user_id, type, category, title, message, status, is_read, created_at
		FROM notifications 
		WHERE user_id = $1 
		ORDER BY created_at DESC 
		LIMIT 50`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get notifications"})
		return
	}
	defer rows.Close()

	var notifications []Notification
	for rows.Next() {
		var n Notification
		rows.Scan(
			&n.ID, &n.UserID, &n.Type, &n.Category,
			&n.Title, &n.Message, &n.Status,
			&n.IsRead, &n.CreatedAt,
		)
		notifications = append(notifications, n)
	}

	c.JSON(http.StatusOK, gin.H{
		"notifications": notifications,
		"count":         len(notifications),
	})
}

func MarkAsRead(c *gin.Context) {
	id := c.Param("id")

	_, err := DB.Exec(`UPDATE notifications SET is_read = true WHERE id = $1`, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to mark as read"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification marked as read"})
}

func MarkAllAsRead(c *gin.Context) {
	userID := c.Param("user_id")

	_, err := DB.Exec(`UPDATE notifications SET is_read = true WHERE user_id = $1`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to mark all as read"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "All notifications marked as read"})
}

func GetUnreadCount(c *gin.Context) {
	userID := c.Param("user_id")

	var count int
	err := DB.QueryRow(`SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false`, userID).Scan(&count)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get count"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"unread_count": count})
}
