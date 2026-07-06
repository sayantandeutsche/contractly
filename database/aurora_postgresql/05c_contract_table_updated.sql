-- =============================================================
-- 05c_contract_table_updated.sql
-- Drop and recreate crm.contract based on actual Salesforce
-- Contract field definitions from apex log
-- Run as: crm_admin
-- Prerequisites: crm.account, crm.contact, crm.opportunity
-- =============================================================

SET search_path = crm, public;

-- ── Drop dependents then contract ─────────────────────────────
DROP TABLE IF EXISTS crm.contract_line_item_seat CASCADE;
DROP TABLE IF EXISTS crm.contract_line_item       CASCADE;
DROP TABLE IF EXISTS crm.clearing_house           CASCADE;
DROP TABLE IF EXISTS crm.contract                 CASCADE;

-- ── Drop old contract enums ───────────────────────────────────
DROP TYPE IF EXISTS crm.contract_status       CASCADE;
DROP TYPE IF EXISTS crm.contract_billing_type CASCADE;

-- ══════════════════════════════════════════════════════════════
-- ENUMS — from actual Salesforce picklist values
-- ══════════════════════════════════════════════════════════════

CREATE TYPE crm.contract_status AS ENUM (
    'Cancelled', 'Terminated', 'Activated', 'Past',
    'Current', 'Upcoming', 'Written-Off', 'Corrected'
);

CREATE TYPE crm.contract_status_code AS ENUM (
    'Draft', 'InApproval', 'Activated', 'Terminated', 'Expired',
    'Rejected', 'Negotiating', 'AwaitingSignature', 'SignatureDeclined',
    'Signed', 'Cancelled', 'Expired2', 'Terminated2'
);

CREATE TYPE crm.contract_billing_type AS ENUM (
    'All Upfront', 'Yearly', 'Custom'
);

CREATE TYPE crm.contract_payment_terms AS ENUM (
    '010_00_00', '030_00_00', '045_00_00', '060_00_00', '090_00_00'
);

CREATE TYPE crm.contract_currency_iso AS ENUM (
    'AUD', 'GBP', 'EUR', 'INR', 'JPY', 'SGD', 'USD'
);

CREATE TYPE crm.contract_agreement_form AS ENUM (
    'Contract', 'Mail', 'PO', 'Self Check Out'
);

CREATE TYPE crm.contract_account_booking_status AS ENUM (
    'NEW_BUSINESS', 'UPGRADE', 'WINBACK', 'RENEWAL', 'UPSELL', 'RENEWAL_UPSELL'
);

CREATE TYPE crm.contract_cancellation_reason AS ENUM (
    'Missing data', 'No budget', 'Competitor offer', 'Organizational reasons',
    'Primary contact left', 'Compliance / legal', 'No response from potential',
    'Outdated', 'Migration', 'Upsell', 'Low Usage', 'Auto-Cancellation',
    'CONTACT_PERSON_LEFT_THE_COMPANY', 'Account Access Too Expensive',
    'ARB-Chargeback', 'Cancelled by Statista: Non Payer',
    'Cancelled by Statista: Sales Manager',
    'Cancelled via Stripe: ARB payment fail', 'Covid-19', 'Data not found',
    'Fraud', 'Global Deal', 'Group Deal', 'Lawyer',
    'Low/No Usage of Platform', 'Missing Cancellation Mark',
    'No need anymore', 'Not happy', 'OFAC', 'Other', 'Out of Business',
    'Point of contact left', 'Precaution Measure', 'Restructuring Internally',
    'Upgrade', 'Contact person left the company', 'No Activity', 'Write-Off',
    'Follow-Up Contract', 'Data clean-up', 'Goodwill', 'Credit Card Dispute',
    'Wrong Amount', 'Wrong Data', 'IP Access Discontinuation',
    'Credit Card Retry Failed'
);

CREATE TYPE crm.contract_cancellation_status AS ENUM (
    'Uncancelled', 'Cancelled', 'Pending'
);

CREATE TYPE crm.contract_clearing_house AS ENUM (
    'GMBH', 'INC', 'LTD', 'PLC', 'SARL', 'KK', 'PTY', 'INDIA'
);

CREATE TYPE crm.contract_deal_type AS ENUM (
    'Single', 'Revenue Split', 'Underutilized Global', 'Global'
);

CREATE TYPE crm.contract_business_language AS ENUM (
    'DE', 'UK', 'FR', 'ES', 'IT', 'NL', 'RU'
);

CREATE TYPE crm.contract_geocode_accuracy AS ENUM (
    'Address', 'NearAddress', 'Block', 'Street', 'ExtendedZip',
    'Zip', 'Neighborhood', 'City', 'County', 'State', 'Unknown'
);

CREATE TYPE crm.contract_healthscore AS ENUM (
    'Excellent', 'Healthy', 'Neutral', 'Unhealthy'
);

CREATE TYPE crm.contract_industry_type AS ENUM (
    'Industry', 'Academia', 'Academia Mixed'
);

CREATE TYPE crm.contract_invoice_post_date AS ENUM (
    'Immediately', 'Upon Contract Start', 'Custom Date'
);

CREATE TYPE crm.contract_liable_office AS ENUM (
    'AMSTERDAM', 'COPENHAGEN', 'GURUGRAM', 'HAMBURG', 'LONDON',
    'MADRID', 'MELBOURNE', 'NEW_YORK', 'PARIS', 'SINGAPORE',
    'TOKYO', 'WARSAW'
);

CREATE TYPE crm.contract_original_service_level AS ENUM (
    'Academia', 'Base', 'Scale', 'Key', 'Named'
);

CREATE TYPE crm.contract_owner_expiration_notice AS ENUM (
    '15', '30', '45', '60', '90', '120'
);

CREATE TYPE crm.contract_payment_status AS ENUM (
    'Invoiced', 'First Reminder', 'Second Redminer', 'Contact AR',
    'Contact CS', 'Hand Over Lawyer', 'On Hold', 'Lawyer', 'Paid',
    'Write Off', 'Write Off Lawyer'
);

CREATE TYPE crm.contract_po_needed AS ENUM ('Yes', 'No');

CREATE TYPE crm.contract_primary_product AS ENUM (
    'SINGLE_ACCOUNT', 'CORPORATE_ACCOUNT', 'CORPORATE_ACCOUNT_LIGHT',
    'CAMPUS_LICENSE', 'CAMPUS_LICENSE_LIGHT', 'CAMPUS_LICENSE_INT',
    'ENTERPRISE_ACCOUNT', 'STUDENT_ACCOUNT', 'BASIC_ACCOUNT_PLUS',
    'BASIC_ACCOUNT', 'CORPORATE_ACCOUNT_CHURNER', 'PREMIUM_ACCOUNT',
    'NONE', 'PROJECT_ACCOUNT'
);

CREATE TYPE crm.contract_profit_center AS ENUM (
    'US', 'Asia', 'EMEA', 'CE'
);

CREATE TYPE crm.contract_service_level AS ENUM (
    'Academia', 'Base', 'Scale', 'Key', 'Named'
);

CREATE TYPE crm.contract_termination_reason AS ENUM (
    'Missing data', 'No budget', 'Competitor offer', 'Organizational reasons',
    'Primary contact left', 'Compliance / legal', 'No response from potential',
    'Outdated', 'Migration', 'Upsell', 'Low Usage', 'Auto-Cancellation',
    'CONTACT_PERSON_LEFT_THE_COMPANY', 'Account Access Too Expensive',
    'ARB-Chargeback', 'Cancelled by Statista: Non Payer',
    'Cancelled by Statista: Sales Manager',
    'Cancelled via Stripe: ARB payment fail', 'Covid-19', 'Data not found',
    'Fraud', 'Global Deal', 'Group Deal', 'Lawyer',
    'Low/No Usage of Platform', 'Missing Cancellation Mark',
    'No need anymore', 'Not happy', 'OFAC', 'Other', 'Out of Business',
    'Point of contact left', 'Precaution Measure', 'Restructuring Internally',
    'Upgrade', 'Contact person left the company', 'No Activity', 'Write-Off',
    'Follow-Up Contract', 'Data clean-up', 'Goodwill', 'Credit Card Dispute',
    'Wrong Amount', 'Wrong Data', 'IP Access Discontinuation',
    'Credit Card Retry Failed'
);

CREATE TYPE crm.contract_termination_status AS ENUM (
    'Written-Off', 'Correction', 'Terminated'
);

CREATE TYPE crm.contract_user_integration_status AS ENUM (
    'Completed', 'EmailMismatch', 'MultipleContractsFound',
    'UserDoesttExistsInSFandDwh', 'UserDoesntExistsInSF',
    'UserDoesntExistsInDwh', 'UserIsNotManager', 'UnlimitedProductsFound'
);

-- ══════════════════════════════════════════════════════════════
-- CONTRACT TABLE
-- ══════════════════════════════════════════════════════════════
CREATE TABLE crm.contract (

  -- ── Core / system ─────────────────────────────────────────
  id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                       UUID NOT NULL REFERENCES crm.tenant(id),
  owner_id                        UUID REFERENCES crm.app_user(id),
  created_by_id                   UUID REFERENCES crm.app_user(id),
  last_modified_by_id             UUID REFERENCES crm.app_user(id),
  account_id                      UUID REFERENCES crm.account(id),
  opportunity_id                  UUID REFERENCES crm.opportunity(id),
  pricebook2_id                   UUID,                          -- Pricebook2Id
  primary_contact_id              UUID REFERENCES crm.contact(id), -- PrimaryContact__c
  activated_by_id                 UUID REFERENCES crm.app_user(id), -- ActivatedById
  company_signed_id               UUID REFERENCES crm.app_user(id), -- CompanySignedId
  customer_signed_id              UUID REFERENCES crm.contact(id),  -- CustomerSignedId
  source_contract_id              UUID,                          -- SourceContract__c (self-ref)
  follow_up_contract_id           UUID,                          -- FollowUpContract__c (self-ref)
  follow_up_opportunity_id        UUID REFERENCES crm.opportunity(id),
  corrected_through_id            UUID,                          -- CorrectedThrough__c (self-ref)
  ship_to_account_id              UUID REFERENCES crm.account(id),
  primary_cs_manager_id           UUID REFERENCES crm.app_user(id),
  original_csm_id                 UUID REFERENCES crm.app_user(id),
  original_owner_id               UUID REFERENCES crm.app_user(id),
  clearing_house_ref_id           UUID,                          -- Clearing_House__c (ref)
  subscription_group_id           UUID,                          -- SubscriptionGroup__c
  tier_country_id                 UUID,                          -- TierCountry__c

  -- ── Identity ──────────────────────────────────────────────
  name                            VARCHAR(80) NOT NULL,          -- Name
  contract_number                 VARCHAR(30),                   -- ContractNumber
  contract_18char_id              VARCHAR(1300),                 -- Contract18CharacterId__c
  offer_number                    VARCHAR(60),                   -- OfferNumber__c
  legacy_id                       VARCHAR(100),                  -- LegacyId__c
  kl_contract_number              VARCHAR(25),                   -- KLContractNumber__c
  backend_user_id                 VARCHAR(25),                   -- BackendUserID__c
  migration_id                    VARCHAR(100),
  description                     TEXT,                          -- Description (32000)
  special_terms                   VARCHAR(4000),                 -- SpecialTerms
  special_conditions              TEXT,                          -- SpecialConditions__c (32768)

  -- ── Status ────────────────────────────────────────────────
  status                          crm.contract_status NOT NULL DEFAULT 'Upcoming',
  status_code                     crm.contract_status_code,      -- StatusCode
  contract_active                 BOOLEAN NOT NULL DEFAULT FALSE, -- ContractActive__c
  contract_status_formula         VARCHAR(1300),                 -- ContractStatus__c (formula)
  cancellation_status             crm.contract_cancellation_status,
  termination_status              crm.contract_termination_status,

  -- ── Dates ─────────────────────────────────────────────────
  start_date                      DATE NOT NULL,                 -- StartDate
  end_date                        DATE,                          -- EndDate
  contract_term                   INTEGER,                       -- ContractTerm (months)
  activated_date                  TIMESTAMPTZ,                   -- ActivatedDate
  last_approved_date              TIMESTAMPTZ,                   -- LastApprovedDate
  company_signed_date             DATE,                          -- CompanySignedDate
  customer_signed_date            DATE,                          -- CustomerSignedDate
  cancellation_date               DATE,                          -- Cancellation_Date__c
  termination_date                DATE,                          -- TerminationDate__c
  notice_period_start             DATE,                          -- NoticePeriodStart__c
  date_of_acceptance              DATE,                          -- DateOfAcceptance__c
  date_of_first_contract          DATE,                          -- DateOfFirstContract__c
  last_activity_date              DATE,                          -- LastActivityDate
  last_referenced_date            TIMESTAMPTZ,                   -- LastReferencedDate
  last_viewed_date                TIMESTAMPTZ,                   -- LastViewedDate
  user_synchronization_date       TIMESTAMPTZ,                   -- UserSynchronizationDate__c

  -- ── Classification ────────────────────────────────────────
  account_booking_status          crm.contract_account_booking_status,
  deal_type                       crm.contract_deal_type,
  industry_type                   crm.contract_industry_type,
  primary_product                 crm.contract_primary_product,
  service_level                   crm.contract_service_level,
  original_service_level          crm.contract_original_service_level,
  service_level_overridden        BOOLEAN NOT NULL DEFAULT FALSE,
  profit_center                   crm.contract_profit_center,
  profit_center_text              VARCHAR(1300),                 -- Profit_Center__c (formula)
  clearing_house                  crm.contract_clearing_house,
  business_language               crm.contract_business_language,
  access_type                     VARCHAR(4099),                 -- AccessType__c (multipicklist)
  connect_tool                    VARCHAR(4099),                 -- Connect_Tool__c (multipicklist)
  sales_channel                   VARCHAR(4099),                 -- SalesChannel__c (multipicklist)
  sales_team_text                 VARCHAR(1300),                 -- Sales_Team__c (formula)
  sales_team_deprecated           VARCHAR(255),                  -- SalesTeam__c (DO NOT USE)

  -- ── Financial ─────────────────────────────────────────────
  annualized_revenue              NUMERIC(18,0),                 -- AnnualizedRevenue__c (ARR)
  annual_revenue                  NUMERIC(18,0),                 -- AnnualRevenue__c
  monthly_revenue                 NUMERIC(18,0),                 -- MonthlyRevenue__c (MRR)
  monthly_revenue_list_price      NUMERIC(18,2),                 -- MonthlyRecurringRevenueListPrice__c
  new_business_revenue            NUMERIC(18,2),                 -- NewBusinessRevenue1__c
  new_business_revenue_old        NUMERIC(18,2),                 -- NewBusinessRevenue__c (old)
  existing_business_revenue       NUMERIC(18,2),                 -- ExistingBusinessRevenue1__c
  existing_business_revenue_old   NUMERIC(18,2),                 -- ExistingBusinessRevenue__c (old)
  total_amount                    NUMERIC(18,2),                 -- TotalAmount__c
  remaining_balance               NUMERIC(18,2),                 -- RemainingBalance__c
  renewal_price_increase_pct      NUMERIC(4,2),                  -- RenewalPriceIncreaseInPercent__c
  currency_iso_code               crm.contract_currency_iso NOT NULL DEFAULT 'USD',

  -- ── Billing / payment ─────────────────────────────────────
  billing_frequency               crm.contract_billing_type,
  billing_cycle                   VARCHAR(100),                  -- Billing_Cycle__c
  billing_email                   VARCHAR(80),                   -- Billing_E_Mail__c
  payment_terms                   crm.contract_payment_terms,
  payment_status                  crm.contract_payment_status,
  payment_status_comments         VARCHAR(255),                  -- PaymentStatusComments__c
  po_number                       VARCHAR(50),                   -- PONumber__c
  po_needed                       crm.contract_po_needed,
  agreement_form                  crm.contract_agreement_form,
  invoice_post_date_support       crm.contract_invoice_post_date,

  -- ── Billing address ───────────────────────────────────────
  billing_street                  VARCHAR(255),                  -- BillingStreet
  billing_city                    VARCHAR(40),                   -- BillingCity
  billing_state                   VARCHAR(80),                   -- BillingState
  billing_state_code              VARCHAR(10),                   -- BillingStateCode
  billing_postal_code             VARCHAR(20),                   -- BillingPostalCode
  billing_country                 VARCHAR(80),                   -- BillingCountry
  billing_country_code            CHAR(2),                       -- BillingCountryCode
  billing_latitude                NUMERIC(18,15),                -- BillingLatitude
  billing_longitude               NUMERIC(18,15),                -- BillingLongitude
  billing_geocode_accuracy        crm.contract_geocode_accuracy, -- BillingGeocodeAccuracy
  deviating_from_account_address  BOOLEAN NOT NULL DEFAULT FALSE,

  -- ── Shipping address ──────────────────────────────────────
  shipping_street                 VARCHAR(255),
  shipping_city                   VARCHAR(40),
  shipping_state                  VARCHAR(80),
  shipping_state_code             VARCHAR(10),
  shipping_postal_code            VARCHAR(20),
  shipping_country                VARCHAR(80),
  shipping_country_code           CHAR(2),
  shipping_latitude               NUMERIC(18,15),
  shipping_longitude              NUMERIC(18,15),
  shipping_geocode_accuracy       crm.contract_geocode_accuracy,

  -- ── Contract seats / hours / credits ──────────────────────
  seats                           NUMERIC(5,0),                  -- Seats__c
  number_of_user                  NUMERIC(5,0),                  -- NumberOfUser__c
  notice_period_in_days           NUMERIC(3,0),                  -- NoticePeriodInDays__c
  total_purchased_hours           NUMERIC(18,2),                 -- TotalPurchasedHours__c
  total_remaining_hours           NUMERIC(18,2),                 -- TotalRemainingHours__c
  total_purchased_credit          NUMERIC(18,2),                 -- TotalPurchasedCredit__c
  total_remaining_credit          NUMERIC(18,2),                 -- TotalRemainingCredit__c
  cli_with_seats                  NUMERIC(18,0),                 -- CLIwithSeats__c
  cli_without_seats               NUMERIC(18,0),                 -- CLI_without_Seats__c
  cli_with_hours                  NUMERIC(18,0),                 -- CLIwithHours__c
  cli_without_hours               NUMERIC(18,0),                 -- CLI_without_Hours__c

  -- ── Engagement / usage metrics ────────────────────────────
  content_views_last_60           NUMERIC(5,0),                  -- ContentViewsWithinLast60Days__c
  content_views_last_90           NUMERIC(12,0),                 -- ContentViewsWithinLast90Days__c
  downloads_last_90               NUMERIC(12,0),                 -- DownloadsWithinLast90Days__c
  research_queries_last_90        NUMERIC(12,0),                 -- ResearchQueriesWithinLast90Days__c
  active_users_last_90            NUMERIC(12,0),                 -- NumberOfActiveUsersInLast90Days__c
  users_with_content_view_60      NUMERIC(5,0),                  -- UsersWithContentViewLast60Days__c

  -- ── Opportunity counts ────────────────────────────────────
  number_of_contracts             NUMERIC(3,0),                  -- NumberOfContracts__c
  open_renewal_opps               NUMERIC(18,0),                 -- NumberOfOpenRenewalOpps__c
  closed_won_renewal_opps         NUMERIC(18,0),                 -- NumberOfClosedWonRenewalOpps__c
  closed_lost_renewal_opps        NUMERIC(18,0),                 -- NumberOfClosedLostRenewalOpps__c
  open_renewal_upsell_opps        NUMERIC(18,0),                 -- NumberOfRenewalUpsellOpps__c
  closed_won_renewal_upsell_opps  NUMERIC(18,0),                 -- NumberOfClosedWonRenewalUpsellOpps__c
  closed_lost_renewal_upsell_opps NUMERIC(18,0),                 -- NumberOfClosedLostRenewalUpsellOpps__c
  open_winback_opps               NUMERIC(18,0),                 -- NumberOfOpenWinbackOpps__c
  closed_won_winback_opps         NUMERIC(18,0),                 -- NumberOfClosedWonWinbackOpps__c
  closed_lost_winback_opps        NUMERIC(18,0),                 -- NumberOfClosedLostWinbackOpps__c
  open_replace_opps               NUMERIC(16,0),                 -- NumberOfOpenReplaceOpportunities__c
  open_update_opps                NUMERIC(16,0),                 -- NumberofOpenUpdateOpportunities__c
  closed_won_followup_opps        NUMERIC(18,0),                 -- NumberOfClosedWonFollowUpOpportunities__c

  -- ── Health / sentiment ────────────────────────────────────
  healthscore                     crm.contract_healthscore,
  cancellation_reason             crm.contract_cancellation_reason,
  termination_reason              crm.contract_termination_reason,
  termination_comments            VARCHAR(255),                  -- Termination_Comments__c
  liable_office                   crm.contract_liable_office,
  liable_office_text              VARCHAR(1300),                 -- Liable_Office__c (formula)
  user_integration_status         crm.contract_user_integration_status,
  owner_expiration_notice         crm.contract_owner_expiration_notice,

  -- ── Signing ───────────────────────────────────────────────
  customer_signed_title           VARCHAR(40),                   -- CustomerSignedTitle

  -- ── Boolean flags ─────────────────────────────────────────
  is_auto_renewal                 BOOLEAN NOT NULL DEFAULT FALSE, -- IsAutoRenewal__c
  is_global                       BOOLEAN NOT NULL DEFAULT FALSE, -- IsGlobal__c
  is_trial                        BOOLEAN NOT NULL DEFAULT FALSE, -- IsTrial__c
  is_win_back                     BOOLEAN NOT NULL DEFAULT FALSE, -- IsWinBack__c
  is_created_automatically        BOOLEAN NOT NULL DEFAULT FALSE, -- IsCreatedAutomatically__c
  has_connect                     BOOLEAN NOT NULL DEFAULT FALSE, -- Has_Connect__c
  is_kl_outbound                  BOOLEAN NOT NULL DEFAULT FALSE, -- isKLOutbound__c
  ended_yesterday                 BOOLEAN NOT NULL DEFAULT FALSE, -- EndedYesterday__c
  exclude_from_user_sync          BOOLEAN NOT NULL DEFAULT FALSE, -- ExcludeFromUserSynchronization__c
  inbound_flag                    BOOLEAN NOT NULL DEFAULT FALSE, -- InboundFlag__c
  notified                        BOOLEAN NOT NULL DEFAULT FALSE, -- Notified__c
  owner_overridden                BOOLEAN NOT NULL DEFAULT FALSE, -- OwnerOverridden__c
  primary_csm_overridden          BOOLEAN NOT NULL DEFAULT FALSE, -- PrimaryCSMOverridden__c
  service_level_override          BOOLEAN NOT NULL DEFAULT FALSE, -- ServiceLevelOverridden__c
  create_opp_automatically        BOOLEAN NOT NULL DEFAULT FALSE, -- Create_Opportunity_Automatically__c

  -- ── Formula / text fields ─────────────────────────────────
  department                      VARCHAR(255),                  -- Department__c
  primary_contact_name            VARCHAR(1300),                 -- Primary_Contact_Name__c
  primary_cs_manager_name         VARCHAR(1300),                 -- Primary_CS_Manager_Name__c
  show_access_method              VARCHAR(1300),                 -- ShowAccessMethod__c
  open_contract_in_kl             VARCHAR(1300),                 -- Open_Contract_in_KL__c

  -- ── Soft delete / audit ───────────────────────────────────
  is_deleted                      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at                      TIMESTAMPTZ,
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Self-referential FKs ──────────────────────────────────────
ALTER TABLE crm.contract
  ADD CONSTRAINT fk_contract_source
  FOREIGN KEY (source_contract_id) REFERENCES crm.contract(id);

ALTER TABLE crm.contract
  ADD CONSTRAINT fk_contract_followup
  FOREIGN KEY (follow_up_contract_id) REFERENCES crm.contract(id);

ALTER TABLE crm.contract
  ADD CONSTRAINT fk_contract_corrected
  FOREIGN KEY (corrected_through_id) REFERENCES crm.contract(id);

-- ── updated_at trigger ────────────────────────────────────────
CREATE TRIGGER trg_contract_updated
  BEFORE UPDATE ON crm.contract
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ── RLS ───────────────────────────────────────────────────────
ALTER TABLE crm.contract ENABLE ROW LEVEL SECURITY;
CREATE POLICY contract_isolation ON crm.contract
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- ── Audit trigger ─────────────────────────────────────────────
CREATE TRIGGER trg_audit_contract
  AFTER INSERT OR UPDATE OR DELETE ON crm.contract
  FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger();

-- ── Recreate contract_line_item ───────────────────────────────
CREATE TABLE crm.contract_line_item (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID NOT NULL REFERENCES crm.tenant(id),
  contract_id             UUID NOT NULL REFERENCES crm.contract(id) ON DELETE CASCADE,
  product_id              UUID REFERENCES crm.product(id),
  pricebook_entry_id      UUID,
  quote_line_item_id      UUID,
  name                    VARCHAR(255) NOT NULL,
  description             TEXT,
  sort_order              INT,
  quantity                NUMERIC(18,4) NOT NULL DEFAULT 1,
  unit_price              NUMERIC(18,2) NOT NULL,
  discount                NUMERIC(8,4),
  total_price             NUMERIC(18,2) NOT NULL,
  billing_frequency       crm.contract_billing_type,
  start_date              DATE,
  end_date                DATE,
  is_deleted              BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID REFERENCES crm.app_user(id),
  last_modified_by_id     UUID REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE crm.contract_line_item ENABLE ROW LEVEL SECURITY;
CREATE POLICY cli_isolation ON crm.contract_line_item
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);
CREATE TRIGGER trg_cli_updated BEFORE UPDATE ON crm.contract_line_item
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();
CREATE TRIGGER trg_audit_contract_line_item
  AFTER INSERT OR UPDATE OR DELETE ON crm.contract_line_item
  FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger();

-- ── Recreate contract_line_item_seat ──────────────────────────
CREATE TABLE crm.contract_line_item_seat (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID NOT NULL REFERENCES crm.tenant(id),
  contract_line_item_id   UUID NOT NULL REFERENCES crm.contract_line_item(id) ON DELETE CASCADE,
  contract_id             UUID NOT NULL REFERENCES crm.contract(id),
  seat_number             INT,
  seat_name               VARCHAR(255),
  assigned_contact_id     UUID REFERENCES crm.contact(id),
  assigned_user_id        UUID REFERENCES crm.app_user(id),
  assigned_email          VARCHAR(255),
  is_active               BOOLEAN NOT NULL DEFAULT TRUE,
  activation_date         DATE,
  deactivation_date       DATE,
  seat_price              NUMERIC(18,2),
  is_deleted              BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at              TIMESTAMPTZ,
  created_by_id           UUID REFERENCES crm.app_user(id),
  last_modified_by_id     UUID REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE crm.contract_line_item_seat ENABLE ROW LEVEL SECURITY;
CREATE POLICY clis_isolation ON crm.contract_line_item_seat
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);
CREATE TRIGGER trg_clis_updated BEFORE UPDATE ON crm.contract_line_item_seat
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ── Recreate clearing_house ───────────────────────────────────
CREATE TABLE crm.clearing_house (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               UUID NOT NULL REFERENCES crm.tenant(id),
  source_type             VARCHAR(50) NOT NULL,
  source_id               UUID NOT NULL,
  contract_id             UUID REFERENCES crm.contract(id),
  contract_line_item_id   UUID REFERENCES crm.contract_line_item(id),
  event_type              VARCHAR(50) NOT NULL,
  event_date              DATE NOT NULL,
  due_date                DATE,
  gross_amount            NUMERIC(18,2) NOT NULL,
  tax_amount              NUMERIC(18,2) NOT NULL DEFAULT 0,
  net_amount              NUMERIC(18,2) NOT NULL,
  currency_iso_code       CHAR(3) NOT NULL DEFAULT 'USD',
  recognition_start_date  DATE,
  recognition_end_date    DATE,
  recognized_amount       NUMERIC(18,2),
  deferred_amount         NUMERIC(18,2),
  status                  VARCHAR(50) NOT NULL DEFAULT 'Pending',
  processed_at            TIMESTAMPTZ,
  cleared_at              TIMESTAMPTZ,
  external_reference      VARCHAR(255),
  is_deleted              BOOLEAN NOT NULL DEFAULT FALSE,
  created_by_id           UUID REFERENCES crm.app_user(id),
  last_modified_by_id     UUID REFERENCES crm.app_user(id),
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE crm.clearing_house ENABLE ROW LEVEL SECURITY;
CREATE POLICY ch_isolation ON crm.clearing_house
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);
CREATE TRIGGER trg_ch_updated BEFORE UPDATE ON crm.clearing_house
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();
CREATE TRIGGER trg_audit_clearing_house
  AFTER INSERT OR UPDATE OR DELETE ON crm.clearing_house
  FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger();

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX idx_contract_tenant         ON crm.contract (tenant_id);
CREATE INDEX idx_contract_account        ON crm.contract (tenant_id, account_id);
CREATE INDEX idx_contract_owner          ON crm.contract (tenant_id, owner_id);
CREATE INDEX idx_contract_status         ON crm.contract (tenant_id, status);
CREATE INDEX idx_contract_end_date       ON crm.contract (tenant_id, end_date);
CREATE INDEX idx_contract_start_date     ON crm.contract (tenant_id, start_date);
CREATE INDEX idx_contract_created        ON crm.contract (tenant_id, created_at DESC);
CREATE INDEX idx_contract_not_deleted    ON crm.contract (tenant_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_contract_active         ON crm.contract (tenant_id, end_date)
  WHERE status IN ('Current','Activated') AND is_deleted = FALSE;
CREATE INDEX idx_contract_auto_renew     ON crm.contract (tenant_id, end_date)
  WHERE is_auto_renewal = TRUE AND status IN ('Current','Activated') AND is_deleted = FALSE;
CREATE INDEX idx_contract_opportunity    ON crm.contract (tenant_id, opportunity_id);
CREATE INDEX idx_contract_profit_center  ON crm.contract (tenant_id, profit_center);
CREATE INDEX idx_contract_service_level  ON crm.contract (tenant_id, service_level);
CREATE INDEX idx_contract_primary_prod   ON crm.contract (tenant_id, primary_product);
CREATE INDEX idx_contract_csm            ON crm.contract (tenant_id, primary_cs_manager_id);
CREATE INDEX idx_contract_arr            ON crm.contract (tenant_id, annualized_revenue DESC)
  WHERE is_deleted = FALSE;
CREATE INDEX idx_contract_payment_status ON crm.contract (tenant_id, payment_status)
  WHERE is_deleted = FALSE;
CREATE INDEX idx_contract_cancellation   ON crm.contract (tenant_id, cancellation_date)
  WHERE cancellation_status = 'Pending' AND is_deleted = FALSE;
CREATE INDEX idx_cli_contract            ON crm.contract_line_item (tenant_id, contract_id);
CREATE INDEX idx_cli_product             ON crm.contract_line_item (tenant_id, product_id);
CREATE INDEX idx_clis_cli                ON crm.contract_line_item_seat (tenant_id, contract_line_item_id);
CREATE INDEX idx_clis_contract           ON crm.contract_line_item_seat (tenant_id, contract_id);
CREATE INDEX idx_clis_contact            ON crm.contract_line_item_seat (tenant_id, assigned_contact_id);
CREATE INDEX idx_clis_active             ON crm.contract_line_item_seat (tenant_id, contract_id)
  WHERE is_active = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_ch_tenant               ON crm.clearing_house (tenant_id);
CREATE INDEX idx_ch_contract             ON crm.clearing_house (tenant_id, contract_id);
CREATE INDEX idx_ch_event_date           ON crm.clearing_house (tenant_id, event_date);
CREATE INDEX idx_ch_status               ON crm.clearing_house (tenant_id, status);
CREATE INDEX idx_ch_pending              ON crm.clearing_house (tenant_id, due_date)
  WHERE status = 'Pending' AND is_deleted = FALSE;
