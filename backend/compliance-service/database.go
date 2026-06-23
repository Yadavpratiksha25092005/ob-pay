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

	log.Println("Compliance Service DB connected!")
	createTables()
}

func createTables() {
	query := `
	CREATE TABLE IF NOT EXISTS compliance_checks (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		user_id UUID NOT NULL,
		transaction_id UUID,
		check_type VARCHAR(20) NOT NULL,
		status VARCHAR(20) DEFAULT 'passed',
		risk_score INT DEFAULT 0,
		risk_level VARCHAR(10) DEFAULT 'low',
		reason TEXT,
		created_at TIMESTAMP DEFAULT NOW()
	);

	CREATE TABLE IF NOT EXISTS aml_reports (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		user_id UUID NOT NULL,
		transaction_id UUID,
		amount DECIMAL(15,2) NOT NULL,
		report_type VARCHAR(10) NOT NULL,
		status VARCHAR(20) DEFAULT 'pending',
		description TEXT,
		created_at TIMESTAMP DEFAULT NOW()
	);

	CREATE TABLE IF NOT EXISTS fraud_alerts (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		user_id UUID NOT NULL,
		transaction_id UUID,
		alert_type VARCHAR(30) NOT NULL,
		severity VARCHAR(10) DEFAULT 'low',
		description TEXT,
		is_resolved BOOLEAN DEFAULT false,
		created_at TIMESTAMP DEFAULT NOW()
	);

	CREATE INDEX IF NOT EXISTS idx_compliance_user_id ON compliance_checks(user_id);
	CREATE INDEX IF NOT EXISTS idx_aml_user_id ON aml_reports(user_id);
	CREATE INDEX IF NOT EXISTS idx_fraud_user_id ON fraud_alerts(user_id);
	`

	_, err := DB.Exec(query)
	if err != nil {
		log.Fatal("Table creation failed:", err)
	}

	log.Println("Compliance tables ready!")
}
