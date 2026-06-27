-- =============================================================
-- 04_core_tables.sql
-- Run as: crm_admin
-- Tables: tenant, app_user, lead, account, contact, opportunity,
--         opportunity_contact_role, activity, task
-- =============================================================

SET search_path = crm, public;

-- ── Helper: updated_at auto-trigger function ─────────────────
CREATE OR REPLACE FUNCTION crm.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ═══════════════════════════════════════════════════════════
-- TENANT  (top-level isolation unit)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.tenant (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                VARCHAR(255)  NOT NULL,
  slug                VARCHAR(100)  NOT NULL UNIQUE,   -- subdomain key
  plan                VARCHAR(50)   NOT NULL DEFAULT 'starter',
  is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
  max_users           INT           NOT NULL DEFAULT 10,
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_tenant_updated BEFORE UPDATE ON crm.tenant
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- APP_USER  (CRM user, belongs to a tenant)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.app_user (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID          NOT NULL REFERENCES crm.tenant(id),
  email               VARCHAR(255)  NOT NULL,
  first_name          VARCHAR(100),
  last_name           VARCHAR(100),
  title               VARCHAR(100),
  is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
  is_admin            BOOLEAN       NOT NULL DEFAULT FALSE,
  profile             VARCHAR(100)  NOT NULL DEFAULT 'Standard User',
  last_login_at       TIMESTAMPTZ,
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, email)
);
CREATE TRIGGER trg_app_user_updated BEFORE UPDATE ON crm.app_user
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- CURRENCY  (ISO currencies active per tenant)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.currency (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID          NOT NULL REFERENCES crm.tenant(id),
  iso_code            CHAR(3)       NOT NULL,           -- USD, EUR, GBP
  name                VARCHAR(100)  NOT NULL,
  conversion_rate     NUMERIC(18,6) NOT NULL DEFAULT 1.0,
  is_default          BOOLEAN       NOT NULL DEFAULT FALSE,
  is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
  symbol              VARCHAR(5),
  decimal_places      SMALLINT      NOT NULL DEFAULT 2,
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, iso_code)
);
CREATE TRIGGER trg_currency_updated BEFORE UPDATE ON crm.currency
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- ACCOUNT  (company / organisation)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.account (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID                  NOT NULL REFERENCES crm.tenant(id),
  owner_id                UUID                  REFERENCES crm.app_user(id),
  parent_account_id       UUID                  REFERENCES crm.account(id),    -- hierarchy
  -- Identity
  name                    VARCHAR(255)          NOT NULL,
  account_number          VARCHAR(40),
  type                    crm.account_type,
  industry                crm.account_industry,
  sub_industry            VARCHAR(100),
  ownership               crm.account_ownership,
  rating                  crm.rating,
  record_type             crm.record_type       NOT NULL DEFAULT 'Business',
  -- Financials
  annual_revenue          NUMERIC(18,2),
  number_of_employees     INT,
  currency_iso_code       CHAR(3)               NOT NULL DEFAULT 'USD',
  -- Contact info
  phone                   VARCHAR(40),
  fax                     VARCHAR(40),
  website                 VARCHAR(255),
  -- Billing address
  billing_street          VARCHAR(255),
  billing_city            VARCHAR(100),
  billing_state           VARCHAR(100),
  billing_postal_code     VARCHAR(20),
  billing_country         VARCHAR(100),
  billing_country_code    CHAR(2),
  -- Shipping address
  shipping_street         VARCHAR(255),
  shipping_city           VARCHAR(100),
  shipping_state          VARCHAR(100),
  shipping_postal_code    VARCHAR(20),
  shipping_country        VARCHAR(100),
  shipping_country_code   CHAR(2),
  -- CRM metadata
  description             TEXT,
  sic                     VARCHAR(20),              -- Standard Industry Classification
  ticker_symbol           VARCHAR(20),
  naics_code              VARCHAR(10),
  account_source          crm.lead_source,
  clean_status            VARCHAR(40),
  jigsaw_company_id       VARCHAR(40),
  -- Audit
  is_deleted              BOOLEAN               NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID                  REFERENCES crm.app_user(id),
  last_modified_by_id     UUID                  REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_account_updated BEFORE UPDATE ON crm.account
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- CONTACT  (individual person, linked to account)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.contact (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID                  NOT NULL REFERENCES crm.tenant(id),
  owner_id                UUID                  REFERENCES crm.app_user(id),
  account_id              UUID                  REFERENCES crm.account(id),
  reports_to_id           UUID                  REFERENCES crm.contact(id),    -- org chart
  -- Identity
  salutation              crm.salutation,
  first_name              VARCHAR(100),
  last_name               VARCHAR(100)          NOT NULL,
  name                    VARCHAR(221) GENERATED ALWAYS AS (
                            COALESCE(first_name || ' ', '') || last_name
                          ) STORED,
  title                   VARCHAR(128),
  department              VARCHAR(80),
  -- Contact info
  email                   VARCHAR(255),
  email_opted_out         BOOLEAN               NOT NULL DEFAULT FALSE,
  has_opted_out_of_email  BOOLEAN               NOT NULL DEFAULT FALSE,
  email_bounced_reason    VARCHAR(255),
  email_bounced_date      TIMESTAMPTZ,
  phone                   VARCHAR(40),
  mobile_phone            VARCHAR(40),
  home_phone              VARCHAR(40),
  other_phone             VARCHAR(40),
  fax                     VARCHAR(40),
  -- Address (mirrors account billing)
  mailing_street          VARCHAR(255),
  mailing_city            VARCHAR(100),
  mailing_state           VARCHAR(100),
  mailing_postal_code     VARCHAR(20),
  mailing_country         VARCHAR(100),
  mailing_country_code    CHAR(2),
  other_street            VARCHAR(255),
  other_city              VARCHAR(100),
  other_state             VARCHAR(100),
  other_postal_code       VARCHAR(20),
  other_country           VARCHAR(100),
  -- CRM metadata
  lead_source             crm.lead_source,
  description             TEXT,
  do_not_call             BOOLEAN               NOT NULL DEFAULT FALSE,
  has_opted_out_of_fax    BOOLEAN               NOT NULL DEFAULT FALSE,
  languages__c            VARCHAR(100),
  level__c                VARCHAR(40),
  currency_iso_code       CHAR(3)               NOT NULL DEFAULT 'USD',
  -- Audit
  is_deleted              BOOLEAN               NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID                  REFERENCES crm.app_user(id),
  last_modified_by_id     UUID                  REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_contact_updated BEFORE UPDATE ON crm.contact
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- LEAD  (unqualified prospect — converts to Account+Contact+Opp)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.lead (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID                  NOT NULL REFERENCES crm.tenant(id),
  owner_id                UUID                  REFERENCES crm.app_user(id),
  -- Identity
  salutation              crm.salutation,
  first_name              VARCHAR(100),
  last_name               VARCHAR(100)          NOT NULL,
  name                    VARCHAR(221) GENERATED ALWAYS AS (
                            COALESCE(first_name || ' ', '') || last_name
                          ) STORED,
  title                   VARCHAR(128),
  company                 VARCHAR(255)          NOT NULL,
  -- Contact info
  email                   VARCHAR(255),
  phone                   VARCHAR(40),
  mobile_phone            VARCHAR(40),
  fax                     VARCHAR(40),
  website                 VARCHAR(255),
  -- Address
  street                  VARCHAR(255),
  city                    VARCHAR(100),
  state                   VARCHAR(100),
  postal_code             VARCHAR(20),
  country                 VARCHAR(100),
  country_code            CHAR(2),
  -- Lead details
  status                  crm.lead_status       NOT NULL DEFAULT 'Open - Not Contacted',
  lead_source             crm.lead_source,
  rating                  crm.rating,
  industry                crm.account_industry,
  annual_revenue          NUMERIC(18,2),
  number_of_employees     INT,
  currency_iso_code       CHAR(3)               NOT NULL DEFAULT 'USD',
  -- Conversion
  is_converted            BOOLEAN               NOT NULL DEFAULT FALSE,
  converted_date          DATE,
  converted_account_id    UUID                  REFERENCES crm.account(id),
  converted_contact_id    UUID                  REFERENCES crm.contact(id),
  converted_opportunity_id UUID,
  -- Qualification
  description             TEXT,
  no_of_employees         INT,
  do_not_call             BOOLEAN               NOT NULL DEFAULT FALSE,
  has_opted_out_of_email  BOOLEAN               NOT NULL DEFAULT FALSE,
  has_opted_out_of_fax    BOOLEAN               NOT NULL DEFAULT FALSE,
  email_bounced_reason    VARCHAR(255),
  email_bounced_date      TIMESTAMPTZ,
  -- Audit
  is_deleted              BOOLEAN               NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID                  REFERENCES crm.app_user(id),
  last_modified_by_id     UUID                  REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_lead_updated BEFORE UPDATE ON crm.lead
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- OPPORTUNITY  (sales deal)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.opportunity (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID                  NOT NULL REFERENCES crm.tenant(id),
  owner_id                UUID                  REFERENCES crm.app_user(id),
  account_id              UUID                  REFERENCES crm.account(id),
  -- Identity
  name                    VARCHAR(120)          NOT NULL,
  description             TEXT,
  type                    crm.opportunity_type,
  lead_source             crm.lead_source,
  -- Stage & forecast
  stage_name              crm.opportunity_stage NOT NULL DEFAULT 'Prospecting',
  probability             NUMERIC(5,2),          -- 0.00 – 100.00
  forecast_category       crm.forecast_category NOT NULL DEFAULT 'Pipeline',
  forecast_category_name  VARCHAR(40),
  -- Financials
  amount                  NUMERIC(18,2),
  expected_revenue        NUMERIC(18,2),         -- amount × probability
  close_date              DATE                  NOT NULL,
  currency_iso_code       CHAR(3)               NOT NULL DEFAULT 'USD',
  -- Dates
  push_count              INT                   NOT NULL DEFAULT 0,
  last_stage_change_date  DATE,
  -- Competition
  competitor_name__c      VARCHAR(255),
  -- Outcome
  is_won                  BOOLEAN               NOT NULL DEFAULT FALSE,
  is_closed               BOOLEAN               NOT NULL DEFAULT FALSE,
  -- Audit
  is_deleted              BOOLEAN               NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID                  REFERENCES crm.app_user(id),
  last_modified_by_id     UUID                  REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_opportunity_updated BEFORE UPDATE ON crm.opportunity
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- OPPORTUNITY_CONTACT_ROLE  (many contacts per opportunity)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.opportunity_contact_role (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID                  NOT NULL REFERENCES crm.tenant(id),
  opportunity_id      UUID                  NOT NULL REFERENCES crm.opportunity(id),
  contact_id          UUID                  NOT NULL REFERENCES crm.contact(id),
  role                crm.contact_role,
  is_primary          BOOLEAN               NOT NULL DEFAULT FALSE,
  created_at          TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ           NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, opportunity_id, contact_id)
);
CREATE TRIGGER trg_ocr_updated BEFORE UPDATE ON crm.opportunity_contact_role
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- ACTIVITY  (calls, emails, meetings — parent of task/event)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.activity (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID                  NOT NULL REFERENCES crm.tenant(id),
  owner_id            UUID                  REFERENCES crm.app_user(id),
  -- Polymorphic parent (who_id = contact/lead, what_id = account/opp)
  who_type            VARCHAR(50),
  who_id              UUID,
  what_type           VARCHAR(50),
  what_id             UUID,
  -- Activity details
  type                crm.activity_type     NOT NULL DEFAULT 'Call',
  subject             VARCHAR(255)          NOT NULL,
  description         TEXT,
  activity_date       DATE,
  duration_in_minutes INT,
  -- Audit
  is_deleted          BOOLEAN               NOT NULL DEFAULT FALSE,
  created_by_id       UUID                  REFERENCES crm.app_user(id),
  created_at          TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_activity_updated BEFORE UPDATE ON crm.activity
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- TASK  (actionable to-do, child of activity)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.task (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID                  NOT NULL REFERENCES crm.tenant(id),
  owner_id            UUID                  REFERENCES crm.app_user(id),
  activity_id         UUID                  REFERENCES crm.activity(id),
  who_type            VARCHAR(50),
  who_id              UUID,
  what_type           VARCHAR(50),
  what_id             UUID,
  subject             VARCHAR(255)          NOT NULL,
  description         TEXT,
  status              crm.task_status       NOT NULL DEFAULT 'Not Started',
  priority            crm.task_priority     NOT NULL DEFAULT 'Normal',
  activity_date       DATE,
  reminder_date_time  TIMESTAMPTZ,
  is_reminder_set     BOOLEAN               NOT NULL DEFAULT FALSE,
  is_recurrence       BOOLEAN               NOT NULL DEFAULT FALSE,
  is_closed           BOOLEAN               NOT NULL DEFAULT FALSE,
  is_deleted          BOOLEAN               NOT NULL DEFAULT FALSE,
  created_by_id       UUID                  REFERENCES crm.app_user(id),
  created_at          TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_task_updated BEFORE UPDATE ON crm.task
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();
