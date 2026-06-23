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

	log.Println("Database connected successfully!")
}
