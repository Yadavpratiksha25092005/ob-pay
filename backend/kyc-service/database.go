package main

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func InitDB() {
	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		dbPassword := os.Getenv("DB_PASSWORD")
		if dbPassword == "" {
			dbPassword = "pratiksha123"
		}
		connStr = "host=localhost port=5432 user=postgres password=" + dbPassword + " dbname=obpay_db sslmode=disable"
	}

	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Database connection failed:", err)
	}

	err = DB.Ping()
	if err != nil {
		log.Fatal("Database ping failed:", err)
	}

	log.Println("KYC Service DB connected!")
	createTables()
}

func createTables() {
	query := `
	CREATE TABLE IF NOT EXISTS kyc_profiles (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		user_id UUID UNIQUE NOT NULL,
		full_name VARCHAR(255) NOT NULL,
		date_of_birth VARCHAR(20),
		gender VARCHAR(10),
		address TEXT,
		aadhaar_number VARCHAR(20),
		pan_number VARCHAR(20),
		kyc_status VARCHAR(20) DEFAULT 'pending',
		risk_level VARCHAR(10) DEFAULT 'low',
		created_at TIMESTAMP DEFAULT NOW(),
		updated_at TIMESTAMP DEFAULT NOW()
	);

	CREATE TABLE IF NOT EXISTS kyc_documents (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		user_id UUID NOT NULL,
		document_type VARCHAR(30) NOT NULL,
		document_number VARCHAR(50) NOT NULL,
		status VARCHAR(20) DEFAULT 'pending',
		rejection_reason TEXT,
		verified_at TIMESTAMP,
		created_at TIMESTAMP DEFAULT NOW(),
		updated_at TIMESTAMP DEFAULT NOW()
	);

	CREATE INDEX IF NOT EXISTS idx_kyc_profiles_user_id ON kyc_profiles(user_id);
	CREATE INDEX IF NOT EXISTS idx_kyc_documents_user_id ON kyc_documents(user_id);
	`

	_, err := DB.Exec(query)
	if err != nil {
		log.Fatal("Table creation failed:", err)
	}

	log.Println("KYC tables ready!")
}
