# OB Pay — Test Guide

## Run all tests

```bash
# From each service directory:
cd backend/user-service && go test ./... -v
cd backend/payment-service && go test ./... -v
cd backend/rewards-service && go test ./... -v
```

## Test coverage by service

| Service | File | What it covers |
|---|---|---|
| user-service | `auth_test.go` | JWT generation, validation, TTL, tamper detection |
| user-service | `validate_test.go` | Phone/PIN/email/role/name validation rules |
| user-service | `security_test.go` | Admin self-registration blocked, SQL injection, XSS, oversize payload |
| payment-service | `handler_test.go` | Amount limits, phone validation, JSON malform |
| rewards-service | `rewards_test.go` | Event rules, point calculation, duplicate prevention validation |

## Integration tests (requires PostgreSQL)

Start the DB and services, then:

```bash
# Health checks
curl http://localhost:8000/health
curl http://localhost:8001/health

# Register → Login → Refresh flow
curl -X POST http://localhost:8000/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"9876543210","full_name":"Test User","email":"t@test.com","pin":"1234","role":"customer"}'

curl -X POST http://localhost:8000/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"9876543210","pin":"1234"}'

# Use the refresh_token from login response:
curl -X POST http://localhost:8000/api/v1/users/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"<token>"}'

# Reward event trigger
curl -X POST http://localhost:8000/api/v1/rewards/event \
  -H "Content-Type: application/json" \
  -d '{"user_id":"<uuid>","event_type":"signup_bonus"}'

# Admin analytics overview
curl http://localhost:8000/api/v1/analytics/admin/overview \
  -H "Authorization: Bearer <admin-token>"
```

## Database setup

```bash
psql -U postgres -c "CREATE DATABASE obpay_db;"
psql -U postgres -d obpay_db -f backend/migrations/001_schema_baseline.sql
```
