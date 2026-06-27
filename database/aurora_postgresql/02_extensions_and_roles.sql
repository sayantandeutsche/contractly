-- =============================================================
-- 02_extensions_and_roles.sql
-- Run as: crm_admin (master user)
-- Purpose: Enable extensions, create app role with RLS enforced
-- =============================================================

-- ── Extensions ───────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";       -- gen_random_uuid(), crypt()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- trigram indexes for name search
CREATE EXTENSION IF NOT EXISTS "btree_gin";      -- composite GIN indexes
CREATE EXTENSION IF NOT EXISTS "unaccent";       -- accent-insensitive search

-- ── Application role (used by your app server) ───────────────
-- This role has RLS enforced — it cannot bypass tenant policies.
-- The master user (crm_admin) bypasses RLS by default (superuser).
-- NEVER use crm_admin in application code.

DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'crm_app') THEN
    CREATE ROLE crm_app WITH LOGIN PASSWORD 'CHANGE_ME_BEFORE_USE';
  END IF;
END$$;

-- Grant connect and usage
GRANT CONNECT ON DATABASE crm_dev TO crm_app;
GRANT USAGE ON SCHEMA crm TO crm_app;

-- Grant DML on all current and future tables in crm schema
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA crm TO crm_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA crm
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO crm_app;

-- Grant sequence usage (for serial/identity columns if any)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA crm TO crm_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA crm
  GRANT USAGE, SELECT ON SEQUENCES TO crm_app;

-- ── Read-only role (for analytics / reporting) ───────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'crm_readonly') THEN
    CREATE ROLE crm_readonly WITH LOGIN PASSWORD 'CHANGE_ME_READONLY';
  END IF;
END$$;

GRANT CONNECT ON DATABASE crm_dev TO crm_readonly;
GRANT USAGE ON SCHEMA crm TO crm_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA crm TO crm_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA crm
  GRANT SELECT ON TABLES TO crm_readonly;
