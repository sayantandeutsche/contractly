-- =============================================================
-- 09_seed_data_v2.sql
-- Run as: crm_admin
-- Updated for: 04b_lead, 04c_account, 04d_contact, 05b_opportunity
-- All UUIDs use valid hex prefixes only
-- =============================================================

SET search_path = crm, public;

-- ── Tenants ──────────────────────────────────────────────────
INSERT INTO crm.tenant (id, name, slug, plan) VALUES
  ('11111111-0000-0000-0000-000000000001', 'Acme Corp',  'acme',   'growth'),
  ('22222222-0000-0000-0000-000000000002', 'Globex Ltd', 'globex', 'starter');

-- ── Users ────────────────────────────────────────────────────
INSERT INTO crm.app_user (id, tenant_id, email, first_name, last_name, is_admin) VALUES
  ('f0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','admin@acme.com',   'Alice','Admin', TRUE),
  ('f0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','bob@acme.com',     'Bob',  'Sales', FALSE),
  ('f0000003-0000-0000-0000-000000000002','22222222-0000-0000-0000-000000000002','admin@globex.com', 'Gary', 'Globex',TRUE);

-- ── Currencies ───────────────────────────────────────────────
INSERT INTO crm.currency (tenant_id, iso_code, name, conversion_rate, is_default, symbol) VALUES
  ('11111111-0000-0000-0000-000000000001','USD','US Dollar',     1.000000, TRUE,  '$'),
  ('11111111-0000-0000-0000-000000000001','EUR','Euro',          0.920000, FALSE, '€'),
  ('11111111-0000-0000-0000-000000000001','GBP','British Pound', 0.790000, FALSE, '£'),
  ('22222222-0000-0000-0000-000000000002','EUR','Euro',          1.000000, TRUE,  '€'),
  ('22222222-0000-0000-0000-000000000002','USD','US Dollar',     1.090000, FALSE, '$');

-- ── Products ─────────────────────────────────────────────────
-- product_family enum: Software, Hardware, Services, Training, Support, Subscription, Add-On, Other
INSERT INTO crm.product (id, tenant_id, name, product_code, family, is_active, quantity_unit_of_measure) VALUES
  ('a0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','CRM Platform - Starter',    'CRM-START-001','Subscription',TRUE,'User/Month'),
  ('a0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','CRM Platform - Growth',     'CRM-GROW-001', 'Subscription',TRUE,'User/Month'),
  ('a0000003-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','CRM Platform - Enterprise', 'CRM-ENT-001',  'Subscription',TRUE,'User/Month'),
  ('a0000004-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Onboarding Services',       'SVC-OB-001',   'Services',    TRUE,'Hours'),
  ('a0000005-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Premium Support',           'SUP-PREM-001', 'Support',     TRUE,'User/Year');

-- ── Pricebooks ───────────────────────────────────────────────
INSERT INTO crm.pricebook (id, tenant_id, name, is_standard, is_active) VALUES
  ('b0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Standard Pricebook',TRUE, TRUE),
  ('b0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Partner Pricebook', FALSE,TRUE);

-- ── Pricebook Entries ─────────────────────────────────────────
INSERT INTO crm.pricebook_entry (tenant_id, pricebook_id, product_id, unit_price, currency_iso_code, is_active) VALUES
  ('11111111-0000-0000-0000-000000000001','b0000001-0000-0000-0000-000000000001','a0000001-0000-0000-0000-000000000001',  25.00,'USD',TRUE),
  ('11111111-0000-0000-0000-000000000001','b0000001-0000-0000-0000-000000000001','a0000002-0000-0000-0000-000000000001',  65.00,'USD',TRUE),
  ('11111111-0000-0000-0000-000000000001','b0000001-0000-0000-0000-000000000001','a0000003-0000-0000-0000-000000000001', 120.00,'USD',TRUE),
  ('11111111-0000-0000-0000-000000000001','b0000001-0000-0000-0000-000000000001','a0000004-0000-0000-0000-000000000001', 200.00,'USD',TRUE),
  ('11111111-0000-0000-0000-000000000001','b0000001-0000-0000-0000-000000000001','a0000005-0000-0000-0000-000000000001', 500.00,'USD',TRUE),
  -- Partner pricebook (20% discount)
  ('11111111-0000-0000-0000-000000000001','b0000002-0000-0000-0000-000000000001','a0000002-0000-0000-0000-000000000001',  52.00,'USD',TRUE),
  ('11111111-0000-0000-0000-000000000001','b0000002-0000-0000-0000-000000000001','a0000003-0000-0000-0000-000000000001',  96.00,'USD',TRUE);

-- ── Accounts ─────────────────────────────────────────────────
-- Updated for 04c schema:
--   type        → crm.account_type:   'Competitor (Banned)','OFAC (Restricted)',
--                                     'Master Service Agreement (MSA)',
--                                     'Global Testballoon','Global Deal'
--   industry    → crm.account_industry (uppercase codes e.g. TELECOMMUNICATION___IT)
--   customer_status → crm.account_customer_status
--   currency_iso_code → crm.account_currency_iso
-- NOTE: 'Technology', 'Healthcare', 'Biotechnology' are NOT valid in the new enum.
--       Mapped to nearest equivalent codes from your org.
INSERT INTO crm.account (
  id, tenant_id, owner_id,
  name, type, industry, customer_status,
  annual_revenue, number_of_employees,
  phone, website,
  billing_city, billing_country, billing_country_code,
  currency_iso_code
) VALUES
  (
    'c0000001-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'Initech Inc.',
    'Master Service Agreement (MSA)',   -- account_type
    'TELECOMMUNICATION___IT',           -- account_industry (nearest to Technology)
    'Client',                           -- account_customer_status
    5000000, 120,
    '+1-555-100-2000', 'https://initech.example',
    'Austin', 'United States', 'US',
    'USD'
  ),
  (
    'c0000002-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'Umbrella Corp',
    'Global Testballoon',               -- account_type
    'PHARMA___HEALTH',                  -- account_industry (nearest to Healthcare)
    'Prospect',                         -- account_customer_status
    50000000, 800,
    '+1-555-200-3000', 'https://umbrella.example',
    'Chicago', 'United States', 'US',
    'USD'
  ),
  (
    'c0000003-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000001-0000-0000-0000-000000000001',
    'Massive Dynamic',
    'Master Service Agreement (MSA)',   -- account_type
    'PHARMA___HEALTH',                  -- account_industry (nearest to Biotechnology)
    'Client',                           -- account_customer_status
    120000000, 2400,
    '+44-20-1234-5678', 'https://massivedynamic.example',
    'London', 'United Kingdom', 'GB',
    'GBP'
  );

-- ── Contacts ─────────────────────────────────────────────────
-- Updated for 04d schema:
--   salutation          → crm.contact_salutation: 'MR_','MRS_','MX_','Herr','Frau'
--   lead_source         → crm.contact_lead_source
--   currency_iso_code   → crm.contact_currency_iso
--   last_name NOT NULL, first_name optional
--   generated column 'name' — do NOT insert it
INSERT INTO crm.contact (
  id, tenant_id, owner_id, account_id,
  salutation, first_name, last_name,
  title, email, phone,
  currency_iso_code
) VALUES
  (
    'd0000001-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000001',
    'MR_', 'Peter', 'Gibbons',
    'VP Engineering', 'peter@initech.example', '+1-555-100-2001',
    'USD'
  ),
  (
    'd0000002-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'c0000002-0000-0000-0000-000000000001',
    'MRS_', 'Alice', 'Spencer',
    'CTO', 'alice@umbrella.example', '+1-555-200-3001',
    'USD'
  ),
  (
    'd0000003-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000001-0000-0000-0000-000000000001',
    'c0000003-0000-0000-0000-000000000001',
    'MR_', 'Walter', 'Bishop',
    'Chief Science Officer', 'wbishop@massivedynamic.example', '+44-20-1234-5679',
    'GBP'
  );

-- ── Leads ─────────────────────────────────────────────────────
-- Updated for 04b schema:
--   status       → crm.lead_status:  'Unqualified','New','MQL','Screening',
--                                    'Qualification','Outreach','Converted'
--   lead_source  → crm.lead_source:  'Webform','Cold Call','Inbound', etc.
--   industry     → crm.lead_industry: uppercase codes e.g. TELECOMMUNICATION___IT
--   salutation   → crm.salutation:   'MR_','MRS_','MX_','Herr','Frau'
--   currency_iso_code → crm.lead_currency_iso
--   generated column 'name' — do NOT insert it
INSERT INTO crm.lead (
  tenant_id, owner_id,
  salutation, first_name, last_name,
  company, email, phone,
  status, lead_source, industry,
  currency_iso_code
) VALUES
  (
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'MRS_', 'Sarah', 'Connor',
    'Cyberdyne Systems', 'sconnor@cyberdyne.example', '+1-555-300-4000',
    'Outreach',    -- lead_status (was 'Working - Contacted')
    'Webform',     -- lead_source (was 'Web')
    'TELECOMMUNICATION___IT',
    'USD'
  ),
  (
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'MR_', 'Miles', 'Dyson',
    'Cyberdyne Systems', 'mdyson@cyberdyne.example', '+1-555-300-4001',
    'New',         -- lead_status (was 'Open - Not Contacted')
    'Cold Call',   -- lead_source (was 'Phone Inquiry')
    'TELECOMMUNICATION___IT',
    'USD'
  ),
  (
    '11111111-0000-0000-0000-000000000001',
    'f0000001-0000-0000-0000-000000000001',
    'MRS_', 'Elaine', 'Benes',
    'Pendant Publishing', 'ebenes@pendant.example', '+1-555-400-5000',
    'New',         -- lead_status (was 'Open - Not Contacted')
    'Inbound',     -- lead_source (was 'Advertisement')
    'MEDIA___PUBLISHING',
    'USD'
  );

-- ── Opportunities ─────────────────────────────────────────────
-- Updated for 05b schema:
--   stage_name       → crm.opportunity_stage:
--                      'New','Discovery','Activation','Value Realisation',
--                      'Solution Development','Product Presentation',
--                      'Offer sent','Offer Creation','Quoting Process',
--                      'Negotiation','Verbal Confirmation','Finalisation',
--                      'Closed Won','Closed Lost'
--   forecast_category → crm.forecast_category:
--                       'Omitted','Pipeline','BestCase','MostLikely','Forecast','Closed'
--   currency_iso_code → crm.opp_currency_iso
--   type              → crm.opportunity_type
--   close_date        → NOT NULL
INSERT INTO crm.opportunity (
  id, tenant_id, owner_id, account_id,
  name, type,
  stage_name, amount, close_date,
  probability, forecast_category,
  currency_iso_code
) VALUES
  (
    'e0000001-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000001',
    'Initech CRM Rollout - 50 Seats',
    'NEW_BUSINESS',
    'Quoting Process',   -- was 'Proposal/Price Quote'
    39000.00, '2026-09-30',
    70, 'BestCase',      -- was 'Best Case' → enum value is 'BestCase'
    'USD'
  ),
  (
    'e0000002-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000002-0000-0000-0000-000000000001',
    'c0000002-0000-0000-0000-000000000001',
    'Umbrella Corp Enterprise Deal',
    'NEW_BUSINESS',
    'Discovery',         -- was 'Needs Analysis'
    144000.00, '2026-12-31',
    30, 'Pipeline',
    'USD'
  ),
  (
    'e0000003-0000-0000-0000-000000000001',
    '11111111-0000-0000-0000-000000000001',
    'f0000001-0000-0000-0000-000000000001',
    'c0000003-0000-0000-0000-000000000001',
    'Massive Dynamic Renewal + Expansion',
    'RENEWAL',
    'Negotiation',       -- was 'Negotiation/Review'
    86400.00, '2026-08-31',
    90, 'Forecast',      -- was 'Commit' → enum value is 'Forecast'
    'GBP'
  );

-- ── Opportunity Contact Roles ─────────────────────────────────
-- contact_role enum: 'User Buyer','Billing Contact','Economic Buyer',
--                    'Sabateur','Coach','Technical Buyer','Other'
INSERT INTO crm.opportunity_contact_role (tenant_id, opportunity_id, contact_id, role, is_primary) VALUES
  ('11111111-0000-0000-0000-000000000001','e0000001-0000-0000-0000-000000000001','d0000001-0000-0000-0000-000000000001','Economic Buyer', TRUE),
  ('11111111-0000-0000-0000-000000000001','e0000002-0000-0000-0000-000000000001','d0000002-0000-0000-0000-000000000001','Economic Buyer', TRUE),
  ('11111111-0000-0000-0000-000000000001','e0000003-0000-0000-0000-000000000001','d0000003-0000-0000-0000-000000000001','Technical Buyer',TRUE);

-- ── Verify counts ─────────────────────────────────────────────
SELECT 'tenant'                 AS tbl, COUNT(*) FROM crm.tenant                  UNION ALL
SELECT 'app_user',                       COUNT(*) FROM crm.app_user                UNION ALL
SELECT 'currency',                       COUNT(*) FROM crm.currency                UNION ALL
SELECT 'product',                        COUNT(*) FROM crm.product                 UNION ALL
SELECT 'pricebook',                      COUNT(*) FROM crm.pricebook               UNION ALL
SELECT 'pricebook_entry',                COUNT(*) FROM crm.pricebook_entry         UNION ALL
SELECT 'account',                        COUNT(*) FROM crm.account                 UNION ALL
SELECT 'contact',                        COUNT(*) FROM crm.contact                 UNION ALL
SELECT 'lead',                           COUNT(*) FROM crm.lead                    UNION ALL
SELECT 'opportunity',                    COUNT(*) FROM crm.opportunity             UNION ALL
SELECT 'opportunity_contact_role',       COUNT(*) FROM crm.opportunity_contact_role
ORDER BY 1;
