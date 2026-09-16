CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    phone VARCHAR(50),
    preferred_language VARCHAR(5) DEFAULT 'en',
    country VARCHAR(100),
    is_premium BOOLEAN DEFAULT FALSE,
    subscription_plan VARCHAR(50) DEFAULT 'free',
    subscription_expires_at TIMESTAMPTZ,
    marketing_consent BOOLEAN DEFAULT FALSE,
    data_processing_consent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_active_at TIMESTAMPTZ,
    referral_code VARCHAR(50) UNIQUE,
    referred_by VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS user_vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type VARCHAR(50) NOT NULL,
    fuel_type VARCHAR(50) NOT NULL,
    euro_class VARCHAR(20) NOT NULL,
    license_plate VARCHAR(50),
    vehicle_country VARCHAR(100),
    brand VARCHAR(100),
    model VARCHAR(100),
    year INTEGER,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS trip_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    zone_id VARCHAR(255),
    zone_name VARCHAR(500),
    event_type VARCHAR(50) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    was_allowed BOOLEAN,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_conversations (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id VARCHAR(255) NOT NULL,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    context JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subscription_plans (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    features JSONB,
    is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO subscription_plans (id, name, description, price_monthly, price_yearly, features) VALUES
('free', 'Free', 'Basic zone alerts for Netherlands and Belgium', 0, 0, '{"zones": ["NL", "BE"], "alerts": true, "ai_queries": 5, "trip_log": false}'),
('basic', 'Basic', 'All European zones + trip history', 2.99, 29.99, '{"zones": "all", "alerts": true, "ai_queries": 50, "trip_log": true}'),
('pro', 'Pro', 'All features + AI assistant + route planning', 3.99, 39.99, '{"zones": "all", "alerts": true, "ai_queries": "unlimited", "trip_log": true, "routes": true, "ai_assistant": true}'),
('business', 'Business', 'Fleet management + API access', 19.99, 199.99, '{"zones": "all", "alerts": true, "ai_queries": "unlimited", "trip_log": true, "routes": true, "ai_assistant": true, "fleet": true, "api_access": true}')
ON CONFLICT (id) DO NOTHING;

UPDATE subscription_plans SET price_monthly = 3.99, price_yearly = 39.99 WHERE id = 'pro';

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_vehicles_user_id ON user_vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_trip_logs_user_id ON trip_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_trip_logs_timestamp ON trip_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_session ON ai_conversations(session_id);

-- Crowdsourced driving alerts (Flitsmeister-style cameras / incidents).
CREATE TABLE IF NOT EXISTS hazard_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    device_id VARCHAR(64),
    type VARCHAR(50) NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lon DOUBLE PRECISION NOT NULL,
    heading DOUBLE PRECISION,
    note VARCHAR(280),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    confirm_count INTEGER DEFAULT 0,
    deny_count INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS hazard_votes (
    report_id UUID NOT NULL REFERENCES hazard_reports(id) ON DELETE CASCADE,
    voter_key VARCHAR(80) NOT NULL,
    vote VARCHAR(10) NOT NULL CHECK (vote IN ('confirm', 'deny')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (report_id, voter_key)
);

CREATE TABLE IF NOT EXISTS hazard_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES hazard_reports(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    device_id VARCHAR(64),
    body VARCHAR(280) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hazard_reports_expires ON hazard_reports(expires_at);
CREATE INDEX IF NOT EXISTS idx_hazard_reports_type ON hazard_reports(type);
CREATE INDEX IF NOT EXISTS idx_hazard_reports_geo ON hazard_reports(lat, lon);
CREATE INDEX IF NOT EXISTS idx_hazard_comments_report ON hazard_comments(report_id, created_at);
