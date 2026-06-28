-- =============================================================
-- 09_seed_data.sql
-- Run as: crm_admin
-- Seeds: 2 demo tenants, users, currencies, products,
--        pricebooks, sample leads, accounts, contacts, opps
-- =============================================================

SET search_path = crm, public;

-- ── Tenants ──────────────────────────────────────────────────
INSERT INTO crm.tenant (id, name, slug, plan) VALUES
  ('11111111-0000-0000-0000-000000000001', 'Acme Corp',    'acme',    'growth'),
  ('22222222-0000-0000-0000-000000000002', 'Globex Ltd',   'globex',  'starter');

-- ── Users ────────────────────────────────────────────────────
INSERT INTO crm.app_user (id, tenant_id, email, first_name, last_name, is_admin) VALUES
  ('f0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','admin@acme.com','Alice','Admin',TRUE),
  ('f0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','bob@acme.com','Bob','Sales',FALSE),
  ('f0000003-0000-0000-0000-000000000002','22222222-0000-0000-0000-000000000002','admin@globex.com','Gary','Globex',TRUE);

-- ── Currencies ───────────────────────────────────────────────
INSERT INTO crm.currency (tenant_id, iso_code, name, conversion_rate, is_default, symbol) VALUES
  ('11111111-0000-0000-0000-000000000001','USD','US Dollar',    1.000000, TRUE,  '$'),
  ('11111111-0000-0000-0000-000000000001','EUR','Euro',         0.920000, FALSE, '€'),
  ('11111111-0000-0000-0000-000000000001','GBP','British Pound',0.790000, FALSE, '£'),
  ('22222222-0000-0000-0000-000000000002','EUR','Euro',         1.000000, TRUE,  '€'),
  ('22222222-0000-0000-0000-000000000002','USD','US Dollar',    1.090000, FALSE, '$');

-- ── Products ─────────────────────────────────────────────────
INSERT INTO crm.product (id, tenant_id, name, product_code, family, is_active, quantity_unit_of_measure) VALUES
  ('a0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','CRM Platform - Starter',     'CRM-START-001','Subscription','TRUE','User/Month'),
  ('a0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','CRM Platform - Growth',      'CRM-GROW-001', 'Subscription','TRUE','User/Month'),
  ('a0000003-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','CRM Platform - Enterprise',  'CRM-ENT-001',  'Subscription','TRUE','User/Month'),
  ('a0000004-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Onboarding Services',        'SVC-OB-001',   'Services',    'TRUE','Hours'),
  ('a0000005-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Premium Support',            'SUP-PREM-001', 'Support',     'TRUE','User/Year');

-- ── Pricebooks ───────────────────────────────────────────────
INSERT INTO crm.pricebook (id, tenant_id, name, is_standard, is_active) VALUES
  ('b0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Standard Pricebook', TRUE,  TRUE),
  ('b0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','Partner Pricebook',  FALSE, TRUE);

-- ── Pricebook Entries (Standard) ─────────────────────────────
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
INSERT INTO crm.account (id, tenant_id, owner_id, name, type, industry, annual_revenue, number_of_employees, phone, website, billing_city, billing_country) VALUES
  ('c0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'Initech Inc.','Customer - Direct','Technology',5000000,120,'+1-555-100-2000','https://initech.example','Austin','United States'),
  ('c0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'Umbrella Corp','Prospect','Healthcare',50000000,800,'+1-555-200-3000','https://umbrella.example','Chicago','United States'),
  ('c0000003-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000001-0000-0000-0000-000000000001',
   'Massive Dynamic','Customer - Direct','Biotechnology',120000000,2400,'+44-20-1234-5678','https://massivedynamic.example','London','United Kingdom');

-- ── Contacts ─────────────────────────────────────────────────
INSERT INTO crm.contact (id, tenant_id, owner_id, account_id, first_name, last_name, title, email, phone) VALUES
  ('d0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'c0000001-0000-0000-0000-000000000001','Peter','Gibbons','VP Engineering','peter@initech.example','+1-555-100-2001'),
  ('d0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'c0000002-0000-0000-0000-000000000001','Alice','Spencer','CTO','alice@umbrella.example','+1-555-200-3001'),
  ('d0000003-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000001-0000-0000-0000-000000000001',
   'c0000003-0000-0000-0000-000000000001','Walter','Bishop','Chief Science Officer','wbishop@massivedynamic.example','+44-20-1234-5679');

-- ── Leads ────────────────────────────────────────────────────
INSERT INTO crm.lead (tenant_id, owner_id, first_name, last_name, company, email, phone, status, lead_source, industry) VALUES
  ('11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'Sarah','Connor','Cyberdyne Systems','sconnor@cyberdyne.example','+1-555-300-4000',
   'Working - Contacted','Web','Technology'),
  ('11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'Miles','Dyson','Cyberdyne Systems','mdyson@cyberdyne.example','+1-555-300-4001',
   'Open - Not Contacted','Phone Inquiry','Technology'),
  ('11111111-0000-0000-0000-000000000001','f0000001-0000-0000-0000-000000000001',
   'Elaine','Benes','Pendant Publishing','ebenes@pendant.example','+1-555-400-5000',
   'Open - Not Contacted','Advertisement','Media');

-- ── Opportunities ────────────────────────────────────────────
INSERT INTO crm.opportunity (id, tenant_id, owner_id, account_id, name, stage_name, amount, close_date, probability, forecast_category, currency_iso_code) VALUES
  ('e0000001-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'c0000001-0000-0000-0000-000000000001','Initech CRM Rollout - 50 Seats',
   'Proposal/Price Quote',39000.00,'2026-09-30',70,'Best Case','USD'),
  ('e0000002-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000002-0000-0000-0000-000000000001',
   'c0000002-0000-0000-0000-000000000001','Umbrella Corp Enterprise Deal',
   'Needs Analysis',144000.00,'2026-12-31',30,'Pipeline','USD'),
  ('e0000003-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001','f0000001-0000-0000-0000-000000000001',
   'c0000003-0000-0000-0000-000000000001','Massive Dynamic Renewal + Expansion',
   'Negotiation/Review',86400.00,'2026-08-31',90,'Commit','USD');

-- ── Opportunity Contact Roles ─────────────────────────────────
INSERT INTO crm.opportunity_contact_role (tenant_id, opportunity_id, contact_id, role, is_primary) VALUES
  ('11111111-0000-0000-0000-000000000001','e0000001-0000-0000-0000-000000000001','d0000001-0000-0000-0000-000000000001','Decision Maker',TRUE),
  ('11111111-0000-0000-0000-000000000001','e0000002-0000-0000-0000-000000000001','d0000002-0000-0000-0000-000000000001','Economic Buyer',TRUE),
  ('11111111-0000-0000-0000-000000000001','e0000003-0000-0000-0000-000000000001','d0000003-0000-0000-0000-000000000001','Executive Sponsor',TRUE);

-- ── Verify counts ────────────────────────────────────────────
SELECT 'tenant'                   AS tbl, COUNT(*) FROM crm.tenant            UNION ALL
SELECT 'app_user',                         COUNT(*) FROM crm.app_user          UNION ALL
SELECT 'currency',                         COUNT(*) FROM crm.currency          UNION ALL
SELECT 'product',                          COUNT(*) FROM crm.product           UNION ALL
SELECT 'pricebook',                        COUNT(*) FROM crm.pricebook         UNION ALL
SELECT 'pricebook_entry',                  COUNT(*) FROM crm.pricebook_entry   UNION ALL
SELECT 'account',                          COUNT(*) FROM crm.account           UNION ALL
SELECT 'contact',                          COUNT(*) FROM crm.contact           UNION ALL
SELECT 'lead',                             COUNT(*) FROM crm.lead              UNION ALL
SELECT 'opportunity',                      COUNT(*) FROM crm.opportunity       UNION ALL
SELECT 'opportunity_contact_role',         COUNT(*) FROM crm.opportunity_contact_role
ORDER BY 1;

