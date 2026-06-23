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

	log.Println("Settlement Service DB connected!")
	createTable()
}

func createTable() {
	query := `
	CREATE TABLE IF NOT EXISTS settlements (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		merchant_id UUID NOT NULL,
		amount DECIMAL(15,2) NOT NULL,
		fee DECIMAL(15,2) DEFAULT 0,
		net_amount DECIMAL(15,2) NOT NULL,
		status VARCHAR(20) DEFAULT 'pending',
		bank_account VARCHAR(50) NOT NULL,
		ifsc_code VARCHAR(20) NOT NULL,
		bank_name VARCHAR(100) NOT NULL,
		utr_number VARCHAR(50),
		settlement_date TIMESTAMP,
		created_at TIMESTAMP DEFAULT NOW(),
		updated_at TIMESTAMP DEFAULT NOW()
	);
	CREATE INDEX IF NOT EXISTS idx_settlements_merchant_id ON settlements(merchant_id);
	CREATE INDEX IF NOT EXISTS idx_settlements_status ON settlements(status);
	`

	_, err := DB.Exec(query)
	if err != nil {
		log.Fatal("Table creation failed:", err)
	}

	log.Println("Settlements table ready!")
}
