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

	log.Println("Dispute Service DB connected!")
	createTable()
}

func createTable() {
	query := `
	CREATE TABLE IF NOT EXISTS disputes (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		user_id UUID NOT NULL,
		transaction_id UUID NOT NULL,
		type VARCHAR(30) NOT NULL,
		status VARCHAR(20) DEFAULT 'open',
		title VARCHAR(255) NOT NULL,
		description TEXT NOT NULL,
		amount DECIMAL(15,2) NOT NULL,
		resolution TEXT,
		resolved_at TIMESTAMP,
		created_at TIMESTAMP DEFAULT NOW(),
		updated_at TIMESTAMP DEFAULT NOW()
	);
	CREATE INDEX IF NOT EXISTS idx_disputes_user_id ON disputes(user_id);
	CREATE INDEX IF NOT EXISTS idx_disputes_status ON disputes(status);
	CREATE INDEX IF NOT EXISTS idx_disputes_transaction_id ON disputes(transaction_id);
	`

	_, err := DB.Exec(query)
	if err != nil {
		log.Fatal("Table creation failed:", err)
	}

	log.Println("Disputes table ready!")
}
