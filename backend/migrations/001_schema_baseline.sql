-- ============================================================
-- OB Pay — Baseline Schema Migration
-- Run once against an empty database.
-- Safe to re-run: all statements use IF NOT EXISTS / IF EXISTS.
-- ============================================================

-- ── Enable extension ─────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Users ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone       VARCHAR(15) UNIQUE NOT NULL,
    email       VARCHAR(255),
    full_name   VARCHAR(255) NOT NULL,
    role        VARCHAR(20)  NOT NULL DEFAULT 'customer'
                    CHECK (role IN ('customer','merchant','agent','admin')),
    pin_hash    TEXT NOT NULL,
    fcm_token   TEXT,
    kyc_status  VARCHAR(20) DEFAULT 'pending'
                    CHECK (kyc_status IN ('pending','submitted','approved','rejected')),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role  ON users(role);

-- ── Refresh tokens ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(64) NOT NULL UNIQUE,
    expires_at  TIMESTAMP NOT NULL,
    revoked_at  TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_hash ON refresh_tokens(token_hash);

-- Auto-remove expired/revoked tokens (run periodically or via pg_cron)
-- DELETE FROM refresh_tokens WHERE expires_at < NOW() OR revoked_at IS NOT NULL;

-- ── Wallets ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wallets (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance     DECIMAL(15,2) NOT NULL DEFAULT 0.00
                    CHECK (balance >= 0),
    currency    VARCHAR(3)  NOT NULL DEFAULT 'INR',
    is_frozen   BOOLEAN NOT NULL DEFAULT FALSE,
    daily_limit DECIMAL(15,2) NOT NULL DEFAULT 10000.00,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallets_user ON wallets(user_id);

-- ── Payments ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_user_id   UUID REFERENCES users(id) ON DELETE SET NULL,
    receiver_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    amount           DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    currency         VARCHAR(3) NOT NULL DEFAULT 'INR',
    status           VARCHAR(20) NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','success','failed','refunded')),
    payment_method   VARCHAR(20) NOT NULL DEFAULT 'wallet'
                         CHECK (payment_method IN ('wallet','upi','qr','card','netbanking')),
    description      TEXT,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_sender   ON payments(sender_user_id);
CREATE INDEX IF NOT EXISTS idx_payments_receiver ON payments(receiver_user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status   ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created  ON payments(created_at DESC);

-- ── Transactions (audit log) ─────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type             VARCHAR(20) NOT NULL
                         CHECK (type IN ('credit','debit','refund','fee')),
    amount           DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    currency         VARCHAR(3) NOT NULL DEFAULT 'INR',
    status           VARCHAR(20) NOT NULL DEFAULT 'pending',
    reference_id     UUID REFERENCES payments(id) ON DELETE SET NULL,
    description      TEXT,
    sender_user_id   UUID REFERENCES users(id) ON DELETE SET NULL,
    receiver_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    payment_method   VARCHAR(20) DEFAULT 'wallet',
    balance_before   DECIMAL(15,2) DEFAULT 0,
    balance_after    DECIMAL(15,2) DEFAULT 0,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transactions_user    ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status  ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_ref     ON transactions(reference_id);

-- ── Notifications ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(20) NOT NULL,
    category    VARCHAR(30) NOT NULL,
    title       VARCHAR(255) NOT NULL,
    message     TEXT NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'pending',
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user   ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;

-- ── Settlements ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS settlements (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id      UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    amount           DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    fee              DECIMAL(15,2) NOT NULL DEFAULT 0 CHECK (fee >= 0),
    net_amount       DECIMAL(15,2) NOT NULL CHECK (net_amount >= 0),
    status           VARCHAR(20) NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','processing','completed','failed')),
    bank_account     VARCHAR(50) NOT NULL,
    ifsc_code        VARCHAR(20) NOT NULL,
    bank_name        VARCHAR(100) NOT NULL,
    utr_number       VARCHAR(50),
    settlement_date  TIMESTAMP,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_settlements_merchant ON settlements(merchant_id);
CREATE INDEX IF NOT EXISTS idx_settlements_status   ON settlements(status);

-- ── KYC profiles ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kyc_profiles (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name     VARCHAR(255) NOT NULL,
    date_of_birth VARCHAR(20),
    gender        VARCHAR(10),
    address       TEXT,
    aadhaar_number VARCHAR(20),
    pan_number    VARCHAR(20),
    kyc_status    VARCHAR(20) NOT NULL DEFAULT 'pending'
                      CHECK (kyc_status IN ('pending','submitted','approved','rejected')),
    risk_level    VARCHAR(10) NOT NULL DEFAULT 'low'
                      CHECK (risk_level IN ('low','medium','high')),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kyc_user ON kyc_profiles(user_id);

CREATE TABLE IF NOT EXISTS kyc_documents (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type   VARCHAR(30) NOT NULL,
    document_number VARCHAR(50) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    verified_at     TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kyc_docs_user ON kyc_documents(user_id);

-- ── Disputes ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS disputes (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES payments(id) ON DELETE RESTRICT,
    type           VARCHAR(30) NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'open'
                       CHECK (status IN ('open','investigating','resolved','closed')),
    title          VARCHAR(255) NOT NULL,
    description    TEXT NOT NULL,
    amount         DECIMAL(15,2) NOT NULL CHECK (amount >= 0),
    resolution     TEXT,
    resolved_at    TIMESTAMP,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_disputes_user   ON disputes(user_id);
CREATE INDEX IF NOT EXISTS idx_disputes_tx     ON disputes(transaction_id);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON disputes(status);

-- ── Compliance ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS compliance_checks (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES payments(id) ON DELETE SET NULL,
    check_type     VARCHAR(20) NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'passed',
    risk_score     INT NOT NULL DEFAULT 0,
    risk_level     VARCHAR(10) NOT NULL DEFAULT 'low',
    reason         TEXT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_compliance_user ON compliance_checks(user_id);

CREATE TABLE IF NOT EXISTS aml_reports (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES payments(id) ON DELETE SET NULL,
    amount         DECIMAL(15,2) NOT NULL,
    report_type    VARCHAR(10) NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'pending',
    description    TEXT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fraud_alerts (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES payments(id) ON DELETE SET NULL,
    alert_type     VARCHAR(30) NOT NULL,
    severity       VARCHAR(10) NOT NULL DEFAULT 'low',
    description    TEXT,
    is_resolved    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ── Rewards ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_rewards (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    points         INTEGER NOT NULL DEFAULT 0 CHECK (points >= 0),
    total_earned   INTEGER NOT NULL DEFAULT 0,
    total_redeemed INTEGER NOT NULL DEFAULT 0,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rewards_user ON user_rewards(user_id);

CREATE TABLE IF NOT EXISTS reward_events (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type  VARCHAR(50) NOT NULL,
    ref_id      VARCHAR(100) NOT NULL DEFAULT '',
    points      INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, event_type, ref_id)
);

CREATE INDEX IF NOT EXISTS idx_reward_events_user ON reward_events(user_id);

CREATE TABLE IF NOT EXISTS reward_transactions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points      INTEGER NOT NULL,
    type        VARCHAR(20) NOT NULL CHECK (type IN ('earned','redeemed')),
    description TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reward_tx_user ON reward_transactions(user_id);

CREATE TABLE IF NOT EXISTS offers (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title          VARCHAR(100) NOT NULL,
    subtitle       TEXT,
    code           VARCHAR(50),
    category       VARCHAR(50),
    discount_type  VARCHAR(20),
    discount_value FLOAT,
    min_amount     FLOAT DEFAULT 0,
    valid_till     TIMESTAMP,
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ── Beneficiaries ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS beneficiaries (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    phone       VARCHAR(15) NOT NULL,
    nickname    VARCHAR(50) DEFAULT '',
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, phone)
);

CREATE INDEX IF NOT EXISTS idx_beneficiaries_user ON beneficiaries(user_id);

-- ── Add payment_method column if missing (idempotent) ─────────
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='payments' AND column_name='payment_method'
    ) THEN
        ALTER TABLE payments ADD COLUMN payment_method VARCHAR(20) NOT NULL DEFAULT 'wallet';
    END IF;
END$$;
