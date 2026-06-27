-- =============================================================
-- 03_schema_and_enums.sql
-- Run as: crm_admin
-- Purpose: Create the crm schema and all domain enum types
-- =============================================================

CREATE SCHEMA IF NOT EXISTS crm;

SET search_path = crm, public;

-- ── Lead enums ───────────────────────────────────────────────
CREATE TYPE crm.lead_status AS ENUM (
  'Open - Not Contacted', 'Working - Contacted',
  'Closed - Converted', 'Closed - Not Converted'
);

CREATE TYPE crm.lead_source AS ENUM (
  'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List',
  'Web Site', 'Cold Call', 'Advertisement', 'Employee Referral',
  'External Referral', 'Word of mouth', 'Other', 'Internal'
);

CREATE TYPE crm.salutation AS ENUM (
  'Mr.', 'Ms.', 'Mrs.', 'Dr.', 'Prof.'
);

CREATE TYPE crm.rating AS ENUM (
  'Hot', 'Warm', 'Cold'
);

-- ── Account enums ────────────────────────────────────────────
CREATE TYPE crm.account_type AS ENUM (
  'Prospect', 'Customer - Direct', 'Customer - Channel',
  'Channel Partner / Reseller', 'Installation Partner',
  'Technology Partner', 'Other', 'Competitor', 'Analyst', 'Press'
);

CREATE TYPE crm.account_industry AS ENUM (
  'Agriculture', 'Apparel', 'Banking', 'Biotechnology',
  'Chemicals', 'Communications', 'Construction', 'Consulting',
  'Education', 'Electronics', 'Energy', 'Engineering',
  'Entertainment', 'Environmental', 'Finance', 'Food & Beverage',
  'Government', 'Healthcare', 'Hospitality', 'Insurance',
  'Machinery', 'Manufacturing', 'Media', 'Not For Profit',
  'Recreation', 'Retail', 'Shipping', 'Technology',
  'Telecommunications', 'Transportation', 'Utilities', 'Other'
);

CREATE TYPE crm.account_ownership AS ENUM (
  'Public', 'Private', 'Subsidiary', 'Other'
);

-- ── Opportunity enums ────────────────────────────────────────
CREATE TYPE crm.opportunity_stage AS ENUM (
  'Prospecting', 'Qualification', 'Needs Analysis',
  'Value Proposition', 'Id. Decision Makers',
  'Perception Analysis', 'Proposal/Price Quote',
  'Negotiation/Review', 'Closed Won', 'Closed Lost'
);

CREATE TYPE crm.opportunity_type AS ENUM (
  'Existing Business', 'New Business'
);

CREATE TYPE crm.forecast_category AS ENUM (
  'Pipeline', 'Best Case', 'Commit', 'Omitted', 'Closed'
);

-- ── Contact enums ────────────────────────────────────────────
CREATE TYPE crm.contact_role AS ENUM (
  'Business User', 'Decision Maker', 'Economic Buyer',
  'Economic Decision Maker', 'Evaluator', 'Executive Sponsor',
  'Influencer', 'Technical Buyer', 'Other'
);

-- ── Quote enums ──────────────────────────────────────────────
CREATE TYPE crm.quote_status AS ENUM (
  'Draft', 'Needs Review', 'In Review', 'Approved',
  'Rejected', 'Presented', 'Accepted', 'Denied'
);

CREATE TYPE crm.discount_type AS ENUM (
  'Percentage', 'Amount'
);

-- ── Contract enums ───────────────────────────────────────────
CREATE TYPE crm.contract_status AS ENUM (
  'Draft', 'In Approval Process', 'Activated',
  'Expired', 'Terminated'
);

CREATE TYPE crm.contract_billing_type AS ENUM (
  'Monthly', 'Quarterly', 'Annual', 'Multi-Year', 'One-Time'
);

-- ── Product enums ────────────────────────────────────────────
CREATE TYPE crm.product_family AS ENUM (
  'Software', 'Hardware', 'Services', 'Training',
  'Support', 'Subscription', 'Add-On', 'Other'
);

-- ── Shared / misc enums ──────────────────────────────────────
CREATE TYPE crm.record_type AS ENUM (
  'Business', 'Person'
);

CREATE TYPE crm.activity_type AS ENUM (
  'Call', 'Email', 'Meeting', 'Task', 'Other'
);

CREATE TYPE crm.task_status AS ENUM (
  'Not Started', 'In Progress', 'Completed',
  'Waiting on someone else', 'Deferred'
);

CREATE TYPE crm.task_priority AS ENUM (
  'High', 'Normal', 'Low'
);
