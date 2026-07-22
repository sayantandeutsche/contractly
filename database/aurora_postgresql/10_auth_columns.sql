-- =============================================================
-- 10_auth_columns.sql
-- Run as: crm_admin
-- Purpose: Add local (email/password) + Google OAuth2 login support
--          to crm.app_user, and let the auth code path look up a
--          user/tenant before any tenant context is known.
-- =============================================================

SET search_path = crm, public;

-- ── app_user: credentials + provider info ────────────────────
ALTER TABLE crm.app_user
  ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255),
  ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) NOT NULL DEFAULT 'local',
  ADD COLUMN IF NOT EXISTS google_sub     VARCHAR(255),
  ADD COLUMN IF NOT EXISTS avatar_url     VARCHAR(500);

ALTER TABLE crm.app_user
  ADD CONSTRAINT app_user_auth_provider_chk
    CHECK (auth_provider IN ('local', 'google'));

ALTER TABLE crm.app_user
  ADD CONSTRAINT app_user_auth_identity_chk
    CHECK (
      (auth_provider = 'local'  AND password_hash IS NOT NULL) OR
      (auth_provider = 'google' AND google_sub     IS NOT NULL)
    );

-- One google_sub can only ever map to one app_user
CREATE UNIQUE INDEX IF NOT EXISTS app_user_google_sub_uq
  ON crm.app_user (google_sub) WHERE google_sub IS NOT NULL;

-- Login takes only an email (no tenant selector), so email must be a
-- platform-wide identity key, not just unique within a tenant.
ALTER TABLE crm.app_user
  ADD CONSTRAINT app_user_email_global_uq UNIQUE (email);

-- ── RLS: allow the auth code path to look up users / create
-- tenants before any tenant context exists ───────────────────
-- The bypass flag is only ever set (via SET LOCAL, scoped to the
-- current transaction) by the backend's own signup/login/google-login
-- code path — never derived from client input.

DROP POLICY IF EXISTS tenant_isolation ON crm.tenant;
CREATE POLICY tenant_isolation ON crm.tenant
  AS PERMISSIVE FOR ALL TO crm_app
  USING (
    id = current_setting('app.current_tenant_id', TRUE)::uuid
    OR current_setting('app.bypass_tenant_check', TRUE) = 'on'
  );

DROP POLICY IF EXISTS app_user_isolation ON crm.app_user;
CREATE POLICY app_user_isolation ON crm.app_user
  AS PERMISSIVE FOR ALL TO crm_app
  USING (
    tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid
    OR current_setting('app.bypass_tenant_check', TRUE) = 'on'
  );
