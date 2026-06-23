package main

import (
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func SubmitKYC(c *gin.Context) {
	var req KYCRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	id := uuid.New().String()

	// Insert KYC profile
	query := `INSERT INTO kyc_profiles
		(id, user_id, full_name, date_of_birth, gender, address, 
		aadhaar_number, pan_number, kyc_status, risk_level)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		ON CONFLICT (user_id) DO UPDATE SET
		full_name = $3, date_of_birth = $4, gender = $5,
		address = $6, aadhaar_number = $7, pan_number = $8,
		kyc_status = 'pending', updated_at = NOW()`

	_, err := DB.Exec(query,
		id, req.UserID, req.FullName, req.DateOfBirth,
		req.Gender, req.Address, req.AadhaarNumber,
		req.PANNumber, "pending", "low",
	)
	if err != nil {
		log.Println("KYC submit error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "KYC submission failed",
		})
		return
	}

	// Insert Aadhaar document
	docID := uuid.New().String()
	_, err = DB.Exec(`INSERT INTO kyc_documents
		(id, user_id, document_type, document_number, status)
		VALUES ($1,$2,$3,$4,$5)`,
		docID, req.UserID, "aadhaar", req.AadhaarNumber, "pending",
	)
	if err != nil {
		log.Println("KYC document error:", err)
	}

	// Insert PAN if provided
	if req.PANNumber != "" {
		panID := uuid.New().String()
		DB.Exec(`INSERT INTO kyc_documents
			(id, user_id, document_type, document_number, status)
			VALUES ($1,$2,$3,$4,$5)`,
			panID, req.UserID, "pan", req.PANNumber, "pending",
		)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "KYC submitted successfully",
		"kyc_id":  id,
		"status":  "pending",
		"note":    "KYC will be verified within 24 hours",
	})
}

func GetKYCStatus(c *gin.Context) {
	userID := c.Param("user_id")

	var profile KYCProfile
	err := DB.QueryRow(`
		SELECT id, user_id, full_name, 
		COALESCE(date_of_birth,''), COALESCE(gender,''),
		COALESCE(address,''), COALESCE(aadhaar_number,''),
		COALESCE(pan_number,''), kyc_status, risk_level, created_at
		FROM kyc_profiles WHERE user_id = $1`, userID).Scan(
		&profile.ID, &profile.UserID, &profile.FullName,
		&profile.DateOfBirth, &profile.Gender, &profile.Address,
		&profile.AadhaarNumber, &profile.PANNumber,
		&profile.KYCStatus, &profile.RiskLevel, &profile.CreatedAt,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":      "KYC not found",
			"kyc_status": "not_submitted",
		})
		return
	}

	c.JSON(http.StatusOK, profile)
}

func GetKYCDocuments(c *gin.Context) {
	userID := c.Param("user_id")

	rows, err := DB.Query(`
		SELECT id, user_id, document_type, document_number,
		status, COALESCE(rejection_reason,''), created_at
		FROM kyc_documents WHERE user_id = $1
		ORDER BY created_at DESC`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get documents",
		})
		return
	}
	defer rows.Close()

	var documents []KYCDocument
	for rows.Next() {
		var doc KYCDocument
		rows.Scan(
			&doc.ID, &doc.UserID, &doc.DocumentType,
			&doc.DocumentNumber, &doc.Status,
			&doc.RejectionReason, &doc.CreatedAt,
		)
		documents = append(documents, doc)
	}

	c.JSON(http.StatusOK, gin.H{
		"documents": documents,
		"count":     len(documents),
	})
}

func VerifyDocument(c *gin.Context) {
	var req VerifyDocumentRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	now := time.Now()
	var err error

	if req.Status == "verified" {
		_, err = DB.Exec(`
			UPDATE kyc_documents 
			SET status = $1, verified_at = $2, updated_at = NOW()
			WHERE id = $3`,
			req.Status, now, req.DocumentID,
		)
	} else {
		_, err = DB.Exec(`
			UPDATE kyc_documents 
			SET status = $1, rejection_reason = $2, updated_at = NOW()
			WHERE id = $3`,
			req.Status, req.Reason, req.DocumentID,
		)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Verification failed",
		})
		return
	}

	// Update KYC profile status
	if req.Status == "verified" {
		DB.Exec(`
			UPDATE kyc_profiles SET kyc_status = 'basic', 
			updated_at = NOW()
			WHERE user_id = (
				SELECT user_id FROM kyc_documents WHERE id = $1
			)`, req.DocumentID,
		)
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Document " + req.Status + " successfully",
		"status":  req.Status,
	})
}

func UpdateKYCStatus(c *gin.Context) {
	userID := c.Param("user_id")

	var body struct {
		Status    string `json:"status" binding:"required"`
		RiskLevel string `json:"risk_level"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	riskLevel := body.RiskLevel
	if riskLevel == "" {
		riskLevel = "low"
	}

	_, err := DB.Exec(`
		UPDATE kyc_profiles 
		SET kyc_status = $1, risk_level = $2, updated_at = NOW()
		WHERE user_id = $3`,
		body.Status, riskLevel, userID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Status update failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "KYC status updated",
		"kyc_status": body.Status,
		"risk_level": riskLevel,
	})
}
