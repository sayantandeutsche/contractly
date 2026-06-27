-- =============================================================
-- 05_revenue_tables.sql
-- Run as: crm_admin
-- Tables: product, pricebook, pricebook_entry, quote,
--         quote_line_item, contract, contract_line_item,
--         contract_line_item_seat, clearing_house
-- =============================================================

SET search_path = crm, public;

-- ═══════════════════════════════════════════════════════════
-- PRODUCT  (product catalogue — Salesforce: Product2)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.product (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID                  NOT NULL REFERENCES crm.tenant(id),
  -- Identity
  name                    VARCHAR(255)          NOT NULL,
  product_code            VARCHAR(255),
  description             TEXT,
  family                  crm.product_family,
  -- Availability
  is_active               BOOLEAN               NOT NULL DEFAULT TRUE,
  -- Billing & metrics
  quantity_unit_of_measure VARCHAR(255),
  stock_keeping_unit      VARCHAR(180),
  display_url             VARCHAR(1000),
  external_id             VARCHAR(255),
  external_data_source_id UUID,
  -- Salesforce compatibility fields
  number_of_quantity_install_based_products INT,
  number_of_subscriptions INT,
  -- Audit
  is_deleted              BOOLEAN               NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID                  REFERENCES crm.app_user(id),
  last_modified_by_id     UUID                  REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ           NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, product_code)
);
CREATE TRIGGER trg_product_updated BEFORE UPDATE ON crm.product
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- PRICEBOOK  (Salesforce: Pricebook2)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.pricebook (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID          NOT NULL REFERENCES crm.tenant(id),
  name                VARCHAR(255)  NOT NULL,
  description         TEXT,
  is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
  is_standard         BOOLEAN       NOT NULL DEFAULT FALSE,  -- one standard pricebook per tenant
  is_archived         BOOLEAN       NOT NULL DEFAULT FALSE,
  -- Audit
  is_deleted          BOOLEAN       NOT NULL DEFAULT FALSE,
  deleted_at          TIMESTAMPTZ,
  created_by_id       UUID          REFERENCES crm.app_user(id),
  last_modified_by_id UUID          REFERENCES crm.app_user(id),
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_pricebook_updated BEFORE UPDATE ON crm.pricebook
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- Enforce one standard pricebook per tenant
CREATE UNIQUE INDEX uq_pricebook_standard
  ON crm.pricebook (tenant_id)
  WHERE is_standard = TRUE AND is_deleted = FALSE;

-- ═══════════════════════════════════════════════════════════
-- PRICEBOOK_ENTRY  (product × pricebook × currency price)
-- Salesforce: PricebookEntry
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.pricebook_entry (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           UUID          NOT NULL REFERENCES crm.tenant(id),
  pricebook_id        UUID          NOT NULL REFERENCES crm.pricebook(id),
  product_id          UUID          NOT NULL REFERENCES crm.product(id),
  -- Price
  unit_price          NUMERIC(18,2) NOT NULL,
  currency_iso_code   CHAR(3)       NOT NULL DEFAULT 'USD',
  -- Availability
  is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
  use_standard_price  BOOLEAN       NOT NULL DEFAULT FALSE,
  -- Audit
  is_deleted          BOOLEAN       NOT NULL DEFAULT FALSE,
  deleted_at          TIMESTAMPTZ,
  created_by_id       UUID          REFERENCES crm.app_user(id),
  last_modified_by_id UUID          REFERENCES crm.app_user(id),
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, pricebook_id, product_id, currency_iso_code)
);
CREATE TRIGGER trg_pricebook_entry_updated BEFORE UPDATE ON crm.pricebook_entry
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- QUOTE  (price proposal sent to customer)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.quote (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID                  NOT NULL REFERENCES crm.tenant(id),
  owner_id                UUID                  REFERENCES crm.app_user(id),
  opportunity_id          UUID                  REFERENCES crm.opportunity(id),
  pricebook_id            UUID                  REFERENCES crm.pricebook(id),
  -- Identity
  name                    VARCHAR(255)          NOT NULL,
  quote_number            VARCHAR(30),
  status                  crm.quote_status      NOT NULL DEFAULT 'Draft',
  description             TEXT,
  -- Financials
  subtotal                NUMERIC(18,2)         NOT NULL DEFAULT 0,
  discount                NUMERIC(18,2)         NOT NULL DEFAULT 0,
  discount_type           crm.discount_type     NOT NULL DEFAULT 'Percentage',
  tax                     NUMERIC(18,2)         NOT NULL DEFAULT 0,
  shipping                NUMERIC(18,2)         NOT NULL DEFAULT 0,
  grand_total             NUMERIC(18,2)         NOT NULL DEFAULT 0,
  total_price             NUMERIC(18,2)         NOT NULL DEFAULT 0,
  currency_iso_code       CHAR(3)               NOT NULL DEFAULT 'USD',
  -- Dates
  expiration_date         DATE,
  -- Billing address (copied from account at creation)
  billing_name            VARCHAR(255),
  billing_street          VARCHAR(255),
  billing_city            VARCHAR(100),
  billing_state           VARCHAR(100),
  billing_postal_code     VARCHAR(20),
  billing_country         VARCHAR(100),
  billing_country_code    CHAR(2),
  -- Shipping address
  shipping_name           VARCHAR(255),
  shipping_street         VARCHAR(255),
  shipping_city           VARCHAR(100),
  shipping_state          VARCHAR(100),
  shipping_postal_code    VARCHAR(20),
  shipping_country        VARCHAR(100),
  shipping_country_code   CHAR(2),
  -- Contact
  contact_id              UUID                  REFERENCES crm.contact(id),
  -- Syncing
  is_syncing              BOOLEAN               NOT NULL DEFAULT FALSE,
  -- Audit
  is_deleted              BOOLEAN               NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID                  REFERENCES crm.app_user(id),
  last_modified_by_id     UUID                  REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_quote_updated BEFORE UPDATE ON crm.quote
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- Auto-increment quote number per tenant
CREATE SEQUENCE IF NOT EXISTS crm.quote_number_seq START 1000;

-- ═══════════════════════════════════════════════════════════
-- QUOTE_LINE_ITEM  (individual product line on a quote)
-- Salesforce: QuoteLineItem
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.quote_line_item (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID          NOT NULL REFERENCES crm.tenant(id),
  quote_id                UUID          NOT NULL REFERENCES crm.quote(id) ON DELETE CASCADE,
  product_id              UUID          NOT NULL REFERENCES crm.product(id),
  pricebook_entry_id      UUID          REFERENCES crm.pricebook_entry(id),
  -- Line details
  sort_order              INT,
  description             TEXT,
  -- Quantity & pricing
  quantity                NUMERIC(18,4) NOT NULL DEFAULT 1,
  unit_price              NUMERIC(18,2) NOT NULL,         -- list price
  sales_price             NUMERIC(18,2) NOT NULL,         -- after manual override
  discount                NUMERIC(8,4),                   -- percentage
  total_price             NUMERIC(18,2) NOT NULL,         -- quantity × sales_price
  list_price              NUMERIC(18,2),
  -- Dates
  service_date            DATE,
  end_date                DATE,
  -- Audit
  is_deleted              BOOLEAN       NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID          REFERENCES crm.app_user(id),
  last_modified_by_id     UUID          REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_qli_updated BEFORE UPDATE ON crm.quote_line_item
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- CONTRACT  (executed agreement with a customer)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.contract (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                   UUID                      NOT NULL REFERENCES crm.tenant(id),
  owner_id                    UUID                      REFERENCES crm.app_user(id),
  account_id                  UUID                      REFERENCES crm.account(id),
  opportunity_id              UUID                      REFERENCES crm.opportunity(id),
  quote_id                    UUID                      REFERENCES crm.quote(id),
  pricebook_id                UUID                      REFERENCES crm.pricebook(id),
  -- Identity
  contract_number             VARCHAR(30),
  name                        VARCHAR(255)              NOT NULL,
  description                 TEXT,
  status                      crm.contract_status       NOT NULL DEFAULT 'Draft',
  -- Terms
  start_date                  DATE                      NOT NULL,
  end_date                    DATE,
  contract_term               INT,                      -- months
  billing_type                crm.contract_billing_type NOT NULL DEFAULT 'Annual',
  -- Financials
  total_contract_value        NUMERIC(18,2),
  annual_contract_value       NUMERIC(18,2),
  monthly_recurring_revenue   NUMERIC(18,2),
  currency_iso_code           CHAR(3)                   NOT NULL DEFAULT 'USD',
  -- Billing contact
  billing_contact_id          UUID                      REFERENCES crm.contact(id),
  -- Activation
  activated_date              DATE,
  activated_by_id             UUID                      REFERENCES crm.app_user(id),
  -- Renewal
  auto_renew                  BOOLEAN                   NOT NULL DEFAULT FALSE,
  renewal_term                INT,
  renewal_reminder_days       INT                       NOT NULL DEFAULT 60,
  parent_contract_id          UUID                      REFERENCES crm.contract(id),
  -- Legal
  special_terms               TEXT,
  company_signed_id           UUID                      REFERENCES crm.app_user(id),
  company_signed_date         DATE,
  customer_signed_id          UUID                      REFERENCES crm.contact(id),
  customer_signed_title       VARCHAR(128),
  customer_signed_date        DATE,
  -- Audit
  is_deleted                  BOOLEAN                   NOT NULL DEFAULT FALSE,
  deleted_at                  TIMESTAMPTZ,
  created_by_id               UUID                      REFERENCES crm.app_user(id),
  last_modified_by_id         UUID                      REFERENCES crm.app_user(id),
  created_at                  TIMESTAMPTZ               NOT NULL DEFAULT now(),
  updated_at                  TIMESTAMPTZ               NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_contract_updated BEFORE UPDATE ON crm.contract
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- CONTRACT_LINE_ITEM  (product/service line on a contract)
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.contract_line_item (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID          NOT NULL REFERENCES crm.tenant(id),
  contract_id             UUID          NOT NULL REFERENCES crm.contract(id) ON DELETE CASCADE,
  product_id              UUID          NOT NULL REFERENCES crm.product(id),
  pricebook_entry_id      UUID          REFERENCES crm.pricebook_entry(id),
  quote_line_item_id      UUID          REFERENCES crm.quote_line_item(id),
  -- Line details
  name                    VARCHAR(255)  NOT NULL,
  description             TEXT,
  sort_order              INT,
  -- Quantity & pricing
  quantity                NUMERIC(18,4) NOT NULL DEFAULT 1,
  unit_price              NUMERIC(18,2) NOT NULL,
  discount                NUMERIC(8,4),
  total_price             NUMERIC(18,2) NOT NULL,
  -- Billing
  billing_frequency       crm.contract_billing_type,
  -- Dates
  start_date              DATE,
  end_date                DATE,
  -- Audit
  is_deleted              BOOLEAN       NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID          REFERENCES crm.app_user(id),
  last_modified_by_id     UUID          REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_cli_updated BEFORE UPDATE ON crm.contract_line_item
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- CONTRACT_LINE_ITEM_SEAT  (per-user / per-seat entitlement)
-- Tracks individual seat allocations under a contract line
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.contract_line_item_seat (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                   UUID          NOT NULL REFERENCES crm.tenant(id),
  contract_line_item_id       UUID          NOT NULL REFERENCES crm.contract_line_item(id) ON DELETE CASCADE,
  contract_id                 UUID          NOT NULL REFERENCES crm.contract(id),
  -- Seat identity
  seat_number                 INT,
  seat_name                   VARCHAR(255),
  -- Assignment
  assigned_contact_id         UUID          REFERENCES crm.contact(id),
  assigned_user_id            UUID          REFERENCES crm.app_user(id),
  assigned_email              VARCHAR(255),
  -- Status
  is_active                   BOOLEAN       NOT NULL DEFAULT TRUE,
  activation_date             DATE,
  deactivation_date           DATE,
  -- Pricing (overrides if negotiated per seat)
  seat_price                  NUMERIC(18,2),
  -- Audit
  is_deleted                  BOOLEAN       NOT NULL DEFAULT FALSE,
  deleted_at                  TIMESTAMPTZ,
  created_by_id               UUID          REFERENCES crm.app_user(id),
  last_modified_by_id         UUID          REFERENCES crm.app_user(id),
  created_at                  TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at                  TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_clis_updated BEFORE UPDATE ON crm.contract_line_item_seat
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ═══════════════════════════════════════════════════════════
-- CLEARING_HOUSE  (revenue recognition / payment clearance)
-- Tracks billing events, payment processing, and revenue
-- recognition events against contract line items
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.clearing_house (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                   UUID          NOT NULL REFERENCES crm.tenant(id),
  -- Source reference (polymorphic)
  source_type                 VARCHAR(50)   NOT NULL,   -- 'contract', 'contract_line_item', 'quote'
  source_id                   UUID          NOT NULL,
  contract_id                 UUID          REFERENCES crm.contract(id),
  contract_line_item_id       UUID          REFERENCES crm.contract_line_item(id),
  -- Event details
  event_type                  VARCHAR(50)   NOT NULL,   -- 'invoice', 'payment', 'refund', 'recognition'
  event_date                  DATE          NOT NULL,
  due_date                    DATE,
  -- Amounts
  gross_amount                NUMERIC(18,2) NOT NULL,
  tax_amount                  NUMERIC(18,2) NOT NULL DEFAULT 0,
  net_amount                  NUMERIC(18,2) NOT NULL,
  currency_iso_code           CHAR(3)       NOT NULL DEFAULT 'USD',
  -- Period (for revenue recognition)
  recognition_start_date      DATE,
  recognition_end_date        DATE,
  recognized_amount           NUMERIC(18,2),
  deferred_amount             NUMERIC(18,2),
  -- Status
  status                      VARCHAR(50)   NOT NULL DEFAULT 'Pending',
  -- 'Pending','Processing','Cleared','Failed','Reversed'
  processed_at                TIMESTAMPTZ,
  cleared_at                  TIMESTAMPTZ,
  external_reference          VARCHAR(255),            -- payment gateway txn ID
  -- Audit
  is_deleted                  BOOLEAN       NOT NULL DEFAULT FALSE,
  created_by_id               UUID          REFERENCES crm.app_user(id),
  last_modified_by_id         UUID          REFERENCES crm.app_user(id),
  created_at                  TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at                  TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_clearing_house_updated BEFORE UPDATE ON crm.clearing_house
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();
