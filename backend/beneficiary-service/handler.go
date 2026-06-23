package main

import (
	"net/http"
	"regexp"

	"github.com/gin-gonic/gin"
)

var phoneRegex = regexp.MustCompile(`^\d{10}$`)

// POST /api/v1/beneficiaries
func AddBeneficiary(c *gin.Context) {
	var req AddBeneficiaryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if !phoneRegex.MatchString(req.Phone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Phone must be exactly 10 digits"})
		return
	}

	var id string
	err := DB.QueryRow(`
		INSERT INTO beneficiaries (user_id, name, phone, nickname)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, phone) DO UPDATE SET name = EXCLUDED.name, nickname = EXCLUDED.nickname
		RETURNING id`,
		req.UserID, req.Name, req.Phone, req.Nickname,
	).Scan(&id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save beneficiary"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "Beneficiary saved", "id": id})
}

// GET /api/v1/beneficiaries/:user_id
func GetBeneficiaries(c *gin.Context) {
	userID := c.Param("user_id")
	rows, err := DB.Query(`
		SELECT id, user_id, name, phone, nickname, created_at
		FROM beneficiaries WHERE user_id = $1
		ORDER BY name ASC`, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch beneficiaries"})
		return
	}
	defer rows.Close()

	var list []Beneficiary
	for rows.Next() {
		var b Beneficiary
		rows.Scan(&b.ID, &b.UserID, &b.Name, &b.Phone, &b.Nickname, &b.CreatedAt)
		list = append(list, b)
	}
	if list == nil {
		list = []Beneficiary{}
	}
	c.JSON(http.StatusOK, gin.H{"beneficiaries": list, "count": len(list)})
}

// PUT /api/v1/beneficiaries/:id
func UpdateBeneficiary(c *gin.Context) {
	id := c.Param("id")
	var req UpdateNicknameRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	res, err := DB.Exec(`UPDATE beneficiaries SET nickname = $1 WHERE id = $2`, req.Nickname, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Update failed"})
		return
	}
	if n, _ := res.RowsAffected(); n == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Beneficiary not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Nickname updated"})
}

// DELETE /api/v1/beneficiaries/:id
func DeleteBeneficiary(c *gin.Context) {
	id := c.Param("id")
	res, err := DB.Exec(`DELETE FROM beneficiaries WHERE id = $1`, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Delete failed"})
		return
	}
	if n, _ := res.RowsAffected(); n == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Beneficiary not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Beneficiary removed"})
}
