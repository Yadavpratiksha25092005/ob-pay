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
	if err = DB.Ping(); err != nil {
		log.Fatal("Database ping failed:", err)
	}

	log.Println("Beneficiary Service DB connected!")
	createTable()
}

func createTable() {
	_, err := DB.Exec(`
		CREATE TABLE IF NOT EXISTS beneficiaries (
			id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id    UUID NOT NULL,
			name       VARCHAR(100) NOT NULL,
			phone      VARCHAR(15) NOT NULL,
			nickname   VARCHAR(50) DEFAULT '',
			created_at TIMESTAMP DEFAULT NOW(),
			UNIQUE(user_id, phone)
		);
		CREATE INDEX IF NOT EXISTS idx_beneficiaries_user_id ON beneficiaries(user_id);
	`)
	if err != nil {
		log.Fatal("Table creation failed:", err)
	}
	log.Println("Beneficiaries table ready!")
}
