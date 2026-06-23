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

	log.Println("Transaction Service DB connected!")
	createTable()
}

func createTable() {
	query := `
	CREATE TABLE IF NOT EXISTS transactions (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		user_id UUID NOT NULL,
		type VARCHAR(20) NOT NULL,
		amount DECIMAL(15,2) NOT NULL,
		currency VARCHAR(3) DEFAULT 'INR',
		status VARCHAR(20) DEFAULT 'pending',
		reference_id UUID,
		description TEXT,
		sender_user_id UUID,
		receiver_user_id UUID,
		payment_method VARCHAR(20) DEFAULT 'wallet',
		balance_before DECIMAL(15,2) DEFAULT 0,
		balance_after DECIMAL(15,2) DEFAULT 0,
		created_at TIMESTAMP DEFAULT NOW(),
		updated_at TIMESTAMP DEFAULT NOW()
	);
	CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
	CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
	CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);
	`

	_, err := DB.Exec(query)
	if err != nil {
		log.Fatal("Table creation failed:", err)
	}

	log.Println("Transactions table ready!")
}
