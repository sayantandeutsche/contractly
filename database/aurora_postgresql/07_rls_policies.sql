-- =============================================================
-- 07_rls_policies.sql
-- Run as: crm_admin
-- Enables RLS on every table and creates tenant isolation policies.
-- The app sets: SET LOCAL app.current_tenant_id = '<uuid>'
-- at the start of every transaction.
-- =============================================================

SET search_path = crm, public;

-- ── Helper: current tenant from session config ───────────────
-- Usage in app: SET LOCAL app.current_tenant_id = 'ten-uuid-here';
-- The crm_admin role bypasses RLS by default (BYPASSRLS privilege).
-- crm_app role does NOT bypass RLS — tenant isolation is enforced.

-- ── Enable & create policies for every table ────────────────

-- tenant (admins can see all; app users only their own)
ALTER TABLE crm.tenant ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON crm.tenant
  AS PERMISSIVE FOR ALL TO crm_app
  USING (id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- app_user
ALTER TABLE crm.app_user ENABLE ROW LEVEL SECURITY;
CREATE POLICY app_user_isolation ON crm.app_user
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- currency
ALTER TABLE crm.currency ENABLE ROW LEVEL SECURITY;
CREATE POLICY currency_isolation ON crm.currency
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- account
ALTER TABLE crm.account ENABLE ROW LEVEL SECURITY;
CREATE POLICY account_isolation ON crm.account
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- contact
ALTER TABLE crm.contact ENABLE ROW LEVEL SECURITY;
CREATE POLICY contact_isolation ON crm.contact
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- lead
ALTER TABLE crm.lead ENABLE ROW LEVEL SECURITY;
CREATE POLICY lead_isolation ON crm.lead
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- opportunity
ALTER TABLE crm.opportunity ENABLE ROW LEVEL SECURITY;
CREATE POLICY opportunity_isolation ON crm.opportunity
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- opportunity_contact_role
ALTER TABLE crm.opportunity_contact_role ENABLE ROW LEVEL SECURITY;
CREATE POLICY ocr_isolation ON crm.opportunity_contact_role
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- product
ALTER TABLE crm.product ENABLE ROW LEVEL SECURITY;
CREATE POLICY product_isolation ON crm.product
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- pricebook
ALTER TABLE crm.pricebook ENABLE ROW LEVEL SECURITY;
CREATE POLICY pricebook_isolation ON crm.pricebook
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- pricebook_entry
ALTER TABLE crm.pricebook_entry ENABLE ROW LEVEL SECURITY;
CREATE POLICY pricebook_entry_isolation ON crm.pricebook_entry
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- quote
ALTER TABLE crm.quote ENABLE ROW LEVEL SECURITY;
CREATE POLICY quote_isolation ON crm.quote
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- quote_line_item
ALTER TABLE crm.quote_line_item ENABLE ROW LEVEL SECURITY;
CREATE POLICY qli_isolation ON crm.quote_line_item
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- contract
ALTER TABLE crm.contract ENABLE ROW LEVEL SECURITY;
CREATE POLICY contract_isolation ON crm.contract
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- contract_line_item
ALTER TABLE crm.contract_line_item ENABLE ROW LEVEL SECURITY;
CREATE POLICY cli_isolation ON crm.contract_line_item
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- contract_line_item_seat
ALTER TABLE crm.contract_line_item_seat ENABLE ROW LEVEL SECURITY;
CREATE POLICY clis_isolation ON crm.contract_line_item_seat
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- clearing_house
ALTER TABLE crm.clearing_house ENABLE ROW LEVEL SECURITY;
CREATE POLICY ch_isolation ON crm.clearing_house
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- activity
ALTER TABLE crm.activity ENABLE ROW LEVEL SECURITY;
CREATE POLICY activity_isolation ON crm.activity
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- task
ALTER TABLE crm.task ENABLE ROW LEVEL SECURITY;
CREATE POLICY task_isolation ON crm.task
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- ── HOW TO USE IN YOUR APPLICATION ───────────────────────────
-- At the start of every DB transaction in your app:
--
--   BEGIN;
--   SET LOCAL app.current_tenant_id = 'your-tenant-uuid-here';
--   -- now ALL queries on crm_app are automatically scoped to this tenant
--   SELECT * FROM crm.lead;   -- returns ONLY this tenant's leads
--   COMMIT;
--
-- With ORMs (e.g. Prisma, TypeORM, Sequelize):
--   Execute: SET LOCAL app.current_tenant_id = $1  before any query
--   Best place: in a middleware that wraps every request in a transaction
-- ─────────────────────────────────────────────────────────────
