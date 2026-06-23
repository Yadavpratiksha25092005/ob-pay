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

	createSchema()
	log.Println("Database connected successfully!")
}

func createSchema() {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS users (
			id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			phone       VARCHAR(15) UNIQUE NOT NULL,
			email       VARCHAR(255),
			full_name   VARCHAR(255) NOT NULL,
			role        VARCHAR(20) NOT NULL DEFAULT 'customer',
			pin_hash    TEXT NOT NULL,
			fcm_token   TEXT,
			kyc_status  VARCHAR(20) DEFAULT 'pending',
			is_active   BOOLEAN DEFAULT TRUE,
			created_at  TIMESTAMP DEFAULT NOW(),
			updated_at  TIMESTAMP DEFAULT NOW()
		)`,
		`CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone)`,
		`CREATE INDEX IF NOT EXISTS idx_users_role  ON users(role)`,
		`CREATE TABLE IF NOT EXISTS refresh_tokens (
			id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
			token_hash  VARCHAR(64) NOT NULL UNIQUE,
			expires_at  TIMESTAMP NOT NULL,
			revoked_at  TIMESTAMP,
			created_at  TIMESTAMP DEFAULT NOW()
		)`,
		`CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens(user_id)`,
		`CREATE INDEX IF NOT EXISTS idx_refresh_tokens_hash ON refresh_tokens(token_hash)`,
	}

	for _, q := range queries {
		if _, err := DB.Exec(q); err != nil {
			log.Println("Schema init warning:", err)
		}
	}
}
