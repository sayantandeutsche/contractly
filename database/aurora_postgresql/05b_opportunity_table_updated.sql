-- =============================================================
-- 05b_opportunity_table_updated.sql
-- Drop and recreate crm.opportunity based on actual Salesforce
-- Opportunity field definitions from apex log
-- Run as: crm_admin
-- Prerequisites: crm.account, crm.contact must exist
-- =============================================================

SET search_path = crm, public;

-- ── Drop dependent objects ────────────────────────────────────
DROP TABLE IF EXISTS crm.opportunity_contact_role CASCADE;
DROP TABLE IF EXISTS crm.opportunity              CASCADE;

-- ── Drop old opportunity enums ────────────────────────────────
DROP TYPE IF EXISTS crm.opportunity_stage    CASCADE;
DROP TYPE IF EXISTS crm.opportunity_type     CASCADE;
DROP TYPE IF EXISTS crm.forecast_category    CASCADE;

-- ══════════════════════════════════════════════════════════════
-- ENUMS — from actual Salesforce picklist values
-- ══════════════════════════════════════════════════════════════

CREATE TYPE crm.opportunity_stage AS ENUM (
    'New', 'Discovery', 'Activation', 'Value Realisation',
    'Solution Development', 'Product Presentation', 'Offer sent',
    'Offer Creation', 'Quoting Process', 'Negotiation',
    'Verbal Confirmation', 'Finalisation', 'Closed Won', 'Closed Lost'
);

CREATE TYPE crm.opportunity_type AS ENUM (
    'NEW_BUSINESS', 'UPGRADE', 'WINBACK', 'RENEWAL',
    'UPSELL', 'RENEWAL_UPSELL'
);

CREATE TYPE crm.forecast_category AS ENUM (
    'Omitted', 'Pipeline', 'BestCase', 'MostLikely', 'Forecast', 'Closed'
);

CREATE TYPE crm.opp_forecast_category_name AS ENUM (
    'Omitted', 'Pipeline', 'Best Case', 'Commit', 'Closed'
);

CREATE TYPE crm.opp_lead_source AS ENUM (
    'Academia Availability Request', 'Andzup', 'Apollo', 'Chrunchbase',
    'Clay', 'Client Service', 'Cold Call', 'Cold Mailing', 'Customer Visit',
    'Inbound', 'Linkedin', 'LinkedIn Lead Gen', 'Mailchimp', 'Other',
    'Outbound', 'Partnership', 'Pendo', 'Reference', 'Salesviewer',
    'Seamless.AI', 'Webform', 'Webinar', 'Whitepaper', 'Winmo',
    'Yesware', 'Zoominfo'
);

CREATE TYPE crm.opp_currency_iso AS ENUM (
    'AUD', 'GBP', 'EUR', 'INR', 'JPY', 'SGD', 'USD'
);

CREATE TYPE crm.opp_account_booking_status AS ENUM (
    'NEW_BUSINESS', 'UPGRADE', 'WINBACK', 'RENEWAL', 'UPSELL', 'RENEWAL_UPSELL'
);

CREATE TYPE crm.opp_account_validation_status AS ENUM (
    'Not_Validated', 'Validated', 'Revalidation_Requested'
);

CREATE TYPE crm.opp_agreement_form AS ENUM (
    'Contract', 'Mail', 'PO'
);

CREATE TYPE crm.opp_approval_status AS ENUM (
    'Not necessary', 'Pending', 'Approved', 'Denied'
);

CREATE TYPE crm.opp_ast_status AS ENUM (
    'Unprocessed', 'Processed'
);

CREATE TYPE crm.opp_auto_renewal AS ENUM (
    'Yes', 'No'
);

CREATE TYPE crm.opp_billing_frequency AS ENUM (
    'All Upfront', 'Yearly', 'Custom'
);

CREATE TYPE crm.opp_business_language AS ENUM (
    'DE', 'UK', 'FR', 'ES', 'IT', 'NL', 'RU'
);

CREATE TYPE crm.opp_clearing_house AS ENUM (
    'GMBH', 'INC', 'LTD', 'PLC', 'SARL', 'KK', 'PTY', 'INDIA'
);

CREATE TYPE crm.opp_closing_reason AS ENUM (
    'Competition', 'Comprehensive Solution', 'Contractual/Legal Issues',
    'Customer Engagement', 'Market Knowledge and Expertise',
    'Pricing & Cost', 'Pricing & Value', 'Product or Service Fit',
    'Product Solution & Fit', 'Sales Execution',
    'Strong Relationship & Trust', 'System', 'Timing & Internal Client Factors'
);

CREATE TYPE crm.opp_closing_reason_detail AS ENUM (
    'Budget constraints', 'Contract Cancellation',
    'Customer preferred competitor''s solution', 'Data Offering',
    'Data Quality', 'Feature gaps', 'Follow-up Contract',
    'Incumbent vendor retained', 'Internal priority shift',
    'Lack of communication', 'Lack of trust or credibility',
    'Legal or compliance concerns', 'Lost to competitor', 'Low Usage',
    'No Activity', 'Point of contact change', 'Price increase',
    'Price too high', 'Project postponed or canceled',
    'Technology incompatibility', 'Unclear value proposition',
    'Usability', 'Use Case incompatibility', 'Written-Off',
    'Incorrect Opportunity Data', 'Opportunity Merge', 'Wrong Data',
    'LLM', 'Proprietary data', 'Third party data aggregator',
    'In house team'
);

CREATE TYPE crm.opp_connect_timeline AS ENUM (
    'Immediate', '1-3 Months', '3-6 Months', '6-12 Months', '12+ Months'
);

CREATE TYPE crm.opp_connect_use_case_mode AS ENUM (
    'Mode 1: Internal', 'Mode 2: External'
);

CREATE TYPE crm.opp_db_competitor AS ENUM (
    'Competitor A', 'Competitor B', 'Competitor C'
);

CREATE TYPE crm.opp_deal_type AS ENUM (
    'Single', 'Revenue Split', 'Underutilized Global', 'Global'
);

CREATE TYPE crm.opp_geocode_accuracy AS ENUM (
    'Address', 'NearAddress', 'Block', 'Street', 'ExtendedZip',
    'Zip', 'Neighborhood', 'City', 'County', 'State', 'Unknown'
);

CREATE TYPE crm.opp_industry_type AS ENUM (
    'Industry', 'Academia', 'Academia Mixed'
);

CREATE TYPE crm.opp_invoice_post_date AS ENUM (
    'Immediately', 'Upon Contract Start', 'Custom Date'
);

CREATE TYPE crm.opp_last_signing_status AS ENUM (
    'Draft', 'Pre-Send', 'Send in Progress', 'Canceled / Declined',
    'Expired', 'Created', 'Out for Signature',
    'Waiting for Counter-Signature', 'Signed', 'Out for Approval',
    'Waiting for Counter-Approval', 'Approved', 'Out for Form-Filling',
    'Waiting for Counter-Form-Filling', 'Form-Filled',
    'Out for Acceptance', 'Waiting for Counter-Acceptance', 'Accepted',
    'Out for Delivery', 'Waiting for Counter-Delivery', 'Delivered',
    'Waiting for my Delegation'
);

CREATE TYPE crm.opp_legal_involved AS ENUM ('Yes', 'No');
CREATE TYPE crm.opp_po_needed AS ENUM ('Yes', 'No');
CREATE TYPE crm.opp_procurement_involved AS ENUM ('Yes', 'No');
CREATE TYPE crm.opp_paid_accounts AS ENUM ('Yes', 'No');

CREATE TYPE crm.opp_liable_office AS ENUM (
    'AMSTERDAM', 'COPENHAGEN', 'GURUGRAM', 'HAMBURG', 'LONDON',
    'MADRID', 'MELBOURNE', 'NEW_YORK', 'PARIS', 'SINGAPORE',
    'TOKYO', 'WARSAW'
);

CREATE TYPE crm.opp_onboarding_sentiment AS ENUM (
    'At Risk', 'Ready for Usage'
);

CREATE TYPE crm.opp_original_service_level AS ENUM (
    'Academia', 'Base', 'Scale', 'Key', 'Named'
);

CREATE TYPE crm.opp_payment_terms AS ENUM (
    '010_00_00', '030_00_00', '045_00_00', '060_00_00', '090_00_00'
);

CREATE TYPE crm.opp_platform AS ENUM (
    'ENGLISH', 'GERMAN', 'FRENCH', 'SPANISH', 'EcommerceDB'
);

CREATE TYPE crm.opp_primary_product AS ENUM (
    'SINGLE_ACCOUNT', 'CORPORATE_ACCOUNT', 'CORPORATE_ACCOUNT_LIGHT',
    'CAMPUS_LICENSE', 'CAMPUS_LICENSE_LIGHT', 'CAMPUS_LICENSE_INT',
    'ENTERPRISE_ACCOUNT', 'STUDENT_ACCOUNT', 'BASIC_ACCOUNT_PLUS',
    'BASIC_ACCOUNT', 'CORPORATE_ACCOUNT_CHURNER', 'PREMIUM_ACCOUNT',
    'NONE', 'PROJECT_ACCOUNT'
);

CREATE TYPE crm.opp_product_of_interest AS ENUM (
    'None', 'ASK_STATISTA', 'BASIC_ACCOUNT', 'BASIC_ACCOUNT_PLUS',
    'CAMPUS_LICENSE_INT', 'COMPANY_DATABASE', 'CORPORATE_ACCOUNT',
    'DOSSIER', 'ECOMMERCE_DB', 'ENTERPRISE_ACCOUNT',
    'GLOBAL_CONSUMER_SURVEY', 'PPT_CUSTOMIZATION', 'PROJECT_ACCOUNT',
    'SINGLE_ACCOUNT', 'SINGLE_ACCOUNT_TEST', 'WEBINAR',
    'LICENSE_PRICING', 'LOGIN_ACCESS', 'OTHER', 'PERSONAL_ACCOUNT',
    'PROFESSIONAL_ACCOUNT', 'BUSINESS_SUITE', 'COMPANY_INSIGHTS',
    'CONSUMER_INSIGHTS', 'ECOMMERCE_INSIGHTS', 'STARTER_ACCOUNT',
    'STARTER_ACCOUNT_TEST', 'API'
);

CREATE TYPE crm.opp_profit_center AS ENUM (
    'US', 'Asia', 'EMEA', 'CE', 'ECDB', 'AskStatista'
);

CREATE TYPE crm.opp_renewal_sentiment AS ENUM (
    'Will Churn', 'Might Churn', 'Should Renew', 'Will Renew'
);

CREATE TYPE crm.opp_revenue_range AS ENUM (
    '< 10.000', '10.000 - 50.000', '50.000 - 250.000',
    '250.000 - 500.000', '> 500.000'
);

CREATE TYPE crm.opp_number_registered_users AS ENUM (
    '0 - 9', '10 - 19', '20 - 49', '50 - 99', '100 - 199'
);

CREATE TYPE crm.opp_transfer_status_abt AS ENUM (
    'Pending', 'Successful', 'Failed', 'None'
);

-- ══════════════════════════════════════════════════════════════
-- OPPORTUNITY TABLE
-- ══════════════════════════════════════════════════════════════
CREATE TABLE crm.opportunity (

  -- ── Core / system ─────────────────────────────────────────
  id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                       UUID NOT NULL REFERENCES crm.tenant(id),
  owner_id                        UUID REFERENCES crm.app_user(id),
  created_by_id                   UUID REFERENCES crm.app_user(id),
  last_modified_by_id             UUID REFERENCES crm.app_user(id),
  account_id                      UUID REFERENCES crm.account(id),
  contact_id                      UUID REFERENCES crm.contact(id),       -- ContactId
  primary_contact_id              UUID REFERENCES crm.contact(id),       -- PrimaryContact__c
  contract_id                     UUID,                                  -- ContractId (ref)
  contract_handover_id            UUID,                                  -- ContractHandover__c
  source_contract_id              UUID,                                  -- SourceContract__c
  source_opportunity_id           UUID,                                  -- SourceOpportunity__c
  migration_opportunity_id        UUID,                                  -- MigrationOpportunity__c
  correcting_id                   UUID,                                  -- Correcting__c
  pricebook2_id                   UUID,                                  -- Pricebook2Id
  campaign_id                     UUID,                                  -- CampaignId
  synced_quote_id                 UUID,                                  -- SyncedQuoteId
  signed_quote_id                 UUID,                                  -- SignedQuote__c
  ship_to_account_id              UUID,                                  -- Ship_to_Account__c
  partner_account_id              UUID,                                  -- PartnerAccountId
  client_success_manager_id       UUID,                                  -- Client_Success_Manager__c
  original_csm_id                 UUID,                                  -- Original_CSM__c
  sales_representative_id         UUID,                                  -- Sales_Representative__c
  manager_id                      UUID,                                  -- Manager__c
  group_manager_id                UUID,                                  -- GroupManager__c
  profit_center_head_id           UUID,                                  -- ProfitCenterHead__c
  original_owner_id               UUID,                                  -- OriginalOwner__c
  approver_level_1_id             UUID,                                  -- ApproverLevel_1__c
  approver_level_2_id             UUID,                                  -- ApproverLevel_2__c
  approver_level_3_id             UUID,                                  -- ApproverLevel_3__c
  assigned_approver_id            UUID,                                  -- Assigned_Approver__c
  connect_l1_approver_id          UUID,                                  -- Connect_L1_Approver__c
  outreach_last_touch_contact_id  UUID,                                  -- Outreach_Last_Touch_Contact__c
  case_id                         UUID,                                  -- Case__c
  clearing_house_ref_id           UUID,                                  -- Clearing_House__c (ref)
  ast_id                          UUID,                                  -- AST__c
  prospect_id                     UUID,                                  -- Prospect__c
  tier_country_id                 UUID,                                  -- TierCountry__c

  -- ── Identity ──────────────────────────────────────────────
  name                            VARCHAR(120) NOT NULL,                 -- Name
  description                     TEXT,                                  -- Description (32000)
  opportunity_description         TEXT,                                  -- OpportunityDescription__c (32768)
  ai_summary                      TEXT,                                  -- AI_Summary__c (32768)
  handover_summary_ai             TEXT,                                  -- Handover_Summary_AI__c (32768)
  next_step                       VARCHAR(255),                          -- NextStep
  running_number                  VARCHAR(30),                           -- RunningNumber__c
  migration_id                    VARCHAR(100),                          -- MigrationId__c
  sf_opportunity_id               VARCHAR(1300),                         -- SFOpportunityID__c

  -- ── Stage & forecast ──────────────────────────────────────
  stage_name                      crm.opportunity_stage NOT NULL DEFAULT 'New',
  forecast_category               crm.forecast_category NOT NULL DEFAULT 'Pipeline',
  forecast_category_name          crm.opp_forecast_category_name,
  probability                     NUMERIC(3,0),                          -- Probability (%)
  push_count                      INTEGER NOT NULL DEFAULT 0,            -- PushCount
  is_won                          BOOLEAN NOT NULL DEFAULT FALSE,        -- IsWon
  is_closed                       BOOLEAN NOT NULL DEFAULT FALSE,        -- IsClosed
  is_private                      BOOLEAN NOT NULL DEFAULT FALSE,        -- IsPrivate

  -- ── Type / classification ─────────────────────────────────
  type                            crm.opportunity_type,                  -- Type
  account_booking_status          crm.opp_account_booking_status,       -- AccountBookingStatus__c
  lead_source                     crm.opp_lead_source,                   -- LeadSource
  industry_type                   crm.opp_industry_type,                 -- IndustryType__c
  deal_type                       crm.opp_deal_type,                     -- DealType__c
  platform                        crm.opp_platform,                      -- Platform__c
  profit_center                   crm.opp_profit_center,                 -- Profit_Center__c
  profit_center_deprecated        crm.opp_profit_center,                 -- ProfitCenter__c (DO NOT USE)
  sales_team                      crm.opp_primary_product,               -- SalesTeam__c (stored as text due to very long enum)
  sales_team_text                 VARCHAR(255),                          -- SalesTeam__c actual value
  primary_product                 crm.opp_primary_product,               -- PrimaryProduct__c
  product_of_interest             crm.opp_product_of_interest,           -- ProductofInterest__c
  secondary_products              VARCHAR(4099),                         -- SecondaryProducts__c (multipicklist)
  other_products                  VARCHAR(4099),                         -- OtherProducts__c (multipicklist)
  access_type                     VARCHAR(4099),                         -- AccessType__c (multipicklist)
  original_service_level          crm.opp_original_service_level,        -- OriginalServiceLevel__c
  clearing_house                  crm.opp_clearing_house,                -- ClearingHouse__c
  business_language               crm.opp_business_language,             -- BusinessLanguage__c
  revenue_range                   crm.opp_revenue_range,                 -- Revenue__c
  number_of_registered_users      crm.opp_number_registered_users,       -- NumberOfRegisteredUsers__c
  paid_accounts_in_company        crm.opp_paid_accounts,                 -- PaidAccountsInCompany__c
  liable_office                   crm.opp_liable_office,                 -- LiableOffice__c

  -- ── Financials ────────────────────────────────────────────
  amount                          NUMERIC(18,2),                         -- Amount
  annual_recurring_revenue        NUMERIC(18,2),                         -- AnnualRecurringRevenue__c
  monthly_recurring_revenue       NUMERIC(18,2),                         -- MonthlyRecurringRevenue__c
  monthly_recurring_revenue_list  NUMERIC(18,2),                         -- MonthlyRecurringRevenueListPrice__c
  expected_revenue                NUMERIC(18,2),                         -- ExpectedRevenue
  hidden_expected_revenue         NUMERIC(18,2),                         -- HiddenFieldExpectedRevenue__c
  new_business_revenue            NUMERIC(18,2),                         -- NewBusinessRevenue1__c
  existing_business_revenue       NUMERIC(18,2),                         -- ExistingBusinessRevenue1__c
  already_paid_price              NUMERIC(18,2),                         -- AlreadyPaidPrice__c
  converted_amount                NUMERIC(18,2),                         -- Converted_Amount__c
  remaining_balance               NUMERIC(18,2),                         -- RemainingBalance__c
  total_opportunity_quantity      NUMERIC(18,2),                         -- TotalOpportunityQuantity
  currency_iso_code               crm.opp_currency_iso NOT NULL DEFAULT 'USD',
  renewal_price_increase_pct      NUMERIC(4,2),                          -- RenewalPriceIncreaseInPercent__c
  active_users_percentage         NUMERIC(18,0),                         -- ActiveUsersPercentage__c
  licenses_assigned_percentage    NUMERIC(18,2),                         -- LicensesAssignedPercentage__c
  number_of_users_seats_booked    NUMERIC(18,0),                         -- NumberOfUsersSeatsBooked__c
  number_of_opp_splits            NUMERIC(2,0),                          -- NumberOfOppSplits__c

  -- ── Dates ─────────────────────────────────────────────────
  close_date                      DATE NOT NULL,                         -- CloseDate
  start_date                      DATE,                                  -- StartDate__c
  end_date                        DATE,                                  -- EndDate__c
  calculated_end_date             DATE,                                  -- CalculatedEndDate__c
  source_contract_end_date        DATE,                                  -- SourceContractEndDate__c
  forecast_date                   DATE,                                  -- ForecastDate__c
  quote_validity_date             DATE,                                  -- QuoteValidityDate__c
  date_won                        DATE,                                  -- DateWon__c
  last_activity_date              DATE,                                  -- LastActivityDate
  last_meaningful_connect         DATE,                                  -- LastMeaningfulConnect__c
  pclmc                           DATE,                                  -- PCLMC__c
  current_stage_earliest_due_date DATE,                                  -- CurrentStageEarliestDueDate__c
  todays_date                     DATE,                                  -- TodaysDate__c
  last_stage_change_date          TIMESTAMPTZ,                           -- LastStageChangeDate
  last_referenced_date            TIMESTAMPTZ,                           -- LastReferencedDate
  last_viewed_date                TIMESTAMPTZ,                           -- LastViewedDate
  commit_timestamp                TIMESTAMPTZ,                           -- Commit_Timestamp__c
  booking_approval_datetime       TIMESTAMPTZ,                           -- BookingApprovalDateTime__c
  connect_l1_validated_at         TIMESTAMPTZ,                           -- Connect_L1_Validated_At__c

  -- ── Stage progression timestamps ──────────────────────────
  timestamp_activation            TIMESTAMPTZ,                           -- Timestamp_Activation__c
  timestamp_closed                TIMESTAMPTZ,                           -- Timestamp_Closed__c
  timestamp_discovery             TIMESTAMPTZ,                           -- Timestamp_Discovery__c
  timestamp_finalisation          TIMESTAMPTZ,                           -- Timestamp_Finalisation__c
  timestamp_negotiation           TIMESTAMPTZ,                           -- Timestamp_Negotiation__c
  timestamp_offer_creation        TIMESTAMPTZ,                           -- Timestamp_Offer_Creation__c
  timestamp_solution_development  TIMESTAMPTZ,                           -- Timestamp_Solution_Development__c
  timestamp_value_realization     TIMESTAMPTZ,                           -- Timestamp_Value_Realization__c
  timestamp_waiting               TIMESTAMPTZ,                           -- Timestamp_Waiting__c

  -- ── Contract / term ───────────────────────────────────────
  contract_duration               NUMERIC(18,0),                         -- ContractDuration__c (months)
  contract_duration_upgrade       NUMERIC(18,2),                         -- ContractDurationUpgrade__c
  term_in_months                  NUMERIC(3,0),                          -- TermInMonths__c
  notice_period_in_days           NUMERIC(3,0),                          -- NoticePeriodInDays__c
  auto_renewal                    crm.opp_auto_renewal,                  -- AutoRenewal__c
  is_auto_renewal                 BOOLEAN NOT NULL DEFAULT FALSE,         -- IsAutoRenewal__c
  billing_frequency               crm.opp_billing_frequency,             -- Billing_Frequency__c
  payment_terms                   crm.opp_payment_terms,                 -- PaymentTerms__c
  po_number                       VARCHAR(50),                           -- PONumber__c
  po_needed                       crm.opp_po_needed,                     -- POneeded__c
  agreement_form                  crm.opp_agreement_form,                -- AgreementForm__c
  invoice_post_date_support       crm.opp_invoice_post_date,             -- Invoice_Post_Date_Support__c

  -- ── Approval ──────────────────────────────────────────────
  approval_status                 crm.opp_approval_status,               -- ApprovalStatus__c
  approval_needed                 BOOLEAN NOT NULL DEFAULT FALSE,         -- ApprovalNeeded__c
  approval_level                  VARCHAR(4099),                         -- ApprovalLevel__c (multipicklist)
  reason_for_approval             VARCHAR(4099),                         -- ReasonforApproval__c (multipicklist)
  first_level_approved            BOOLEAN NOT NULL DEFAULT FALSE,         -- FirstLevelApproved__c
  buyer_approved_offer            BOOLEAN NOT NULL DEFAULT FALSE,         -- BuyerApprovedOffer__c
  booking_approval_user           VARCHAR(120),                          -- BookingApprovalUser__c
  approved_snapshot               TEXT,                                  -- ApprovedSnapshot__c (32768)

  -- ── Loss / closing ────────────────────────────────────────
  closing_reason                  crm.opp_closing_reason,                -- ClosingReason__c
  closing_reason_detail           crm.opp_closing_reason_detail,         -- ClosingReasonDetail__c
  loss_reason                     VARCHAR(255),                          -- Loss_Reason__c (long list, text)
  loss_reason_detail              VARCHAR(255),                          -- LossReasonDetail__c
  closed_lost_product_feedback    VARCHAR(1000),                         -- ClosedLostProductFeedback__c
  competitor_information          VARCHAR(255),                          -- Competitor_Information__c
  db_competitor                   crm.opp_db_competitor,                 -- DB_Competitor__c

  -- ── Connect product ───────────────────────────────────────
  has_connect_product             BOOLEAN NOT NULL DEFAULT FALSE,         -- Has_Connect_Product__c
  is_connect_only                 BOOLEAN NOT NULL DEFAULT FALSE,         -- Is_Connect_Only__c
  connect_qualified               NUMERIC(18,0),                         -- Connect_Qualified__c
  connect_implementation_timeline crm.opp_connect_timeline,              -- Connect_Implementation_Timeline__c
  connect_use_case_mode           crm.opp_connect_use_case_mode,         -- Connect_Use_Case_Mode__c
  connect_solution_description    VARCHAR(255),                          -- Connect_Solution_Description__c
  connect_use_case                VARCHAR(255),                          -- Connect_Use_Case__c
  has_api_solutions_consultant    BOOLEAN NOT NULL DEFAULT FALSE,         -- Has_API_Solutions_Consultant__c

  -- ── Billing address (Bill-To) ─────────────────────────────
  billing_street                  VARCHAR(255),                          -- BillingAddress__Street__s
  billing_city                    VARCHAR(40),                           -- BillingAddress__City__s
  billing_state_code              VARCHAR(10),                           -- BillingAddress__StateCode__s
  billing_postal_code             VARCHAR(20),                           -- BillingAddress__PostalCode__s
  billing_country_code            CHAR(2),                               -- BillingAddress__CountryCode__s
  billing_latitude                NUMERIC(18,15),                        -- BillingAddress__Latitude__s
  billing_longitude               NUMERIC(18,15),                        -- BillingAddress__Longitude__s
  billing_geocode_accuracy        crm.opp_geocode_accuracy,              -- BillingAddress__GeocodeAccuracy__s
  billing_house_number            VARCHAR(20),                           -- BillingHouseNumber__c
  billing_street_custom           VARCHAR(120),                          -- BillingStreet__c
  billing_email                   VARCHAR(80),                           -- Billing_E_Mail__c

  -- ── Contact address ───────────────────────────────────────
  contact_address_street          VARCHAR(255),                          -- ContactAddress__Street__s
  contact_address_city            VARCHAR(40),                           -- ContactAddress__City__s
  contact_address_state_code      VARCHAR(10),                           -- ContactAddress__StateCode__s
  contact_address_postal_code     VARCHAR(20),                           -- ContactAddress__PostalCode__s
  contact_address_country_code    CHAR(2),                               -- ContactAddress__CountryCode__s
  contact_address_latitude        NUMERIC(18,15),                        -- ContactAddress__Latitude__s
  contact_address_longitude       NUMERIC(18,15),                        -- ContactAddress__Longitude__s
  contact_address_geocode_acc     crm.opp_geocode_accuracy,              -- ContactAddress__GeocodeAccuracy__s
  contact_house_number            VARCHAR(20),                           -- ContactHouseNumber__c
  contact_street_custom           VARCHAR(120),                          -- ContactStreet__c
  deviating_from_account_address  BOOLEAN NOT NULL DEFAULT FALSE,         -- DeviatingFromAccountAddress__c

  -- ── Ship-To address ───────────────────────────────────────
  ship_to_street                  VARCHAR(255),                          -- ShipToAddress__Street__s
  ship_to_city                    VARCHAR(40),                           -- ShipToAddress__City__s
  ship_to_state_code              VARCHAR(10),                           -- ShipToAddress__StateCode__s
  ship_to_postal_code             VARCHAR(20),                           -- ShipToAddress__PostalCode__s
  ship_to_country_code            CHAR(2),                               -- ShipToAddress__CountryCode__s
  ship_to_latitude                NUMERIC(18,15),                        -- ShipToAddress__Latitude__s
  ship_to_longitude               NUMERIC(18,15),                        -- ShipToAddress__Longitude__s
  ship_to_geocode_accuracy        crm.opp_geocode_accuracy,              -- ShipToAddress__GeocodeAccuracy__s

  -- ── Metrics / scoring ─────────────────────────────────────
  iq_score                        INTEGER,                               -- IqScore
  opportunity_age                 NUMERIC(18,0),                         -- Opportunity_Age__c
  opportunity_count               NUMERIC(18,0),                         -- OpportunityCount__c
  open_risk_count                 NUMERIC(18,0),                         -- OpenRiskCount__c
  number_of_completed_meetings    NUMERIC(18,0),                         -- NumberofCompletedMeeting__c
  days_since_last_mc              NUMERIC(18,0),                         -- DSLMC__c
  qualification_inprogress        NUMERIC(18,0),                         -- Qualification_Inprogress__c
  qualification_not_started       NUMERIC(18,0),                         -- Qualification_Not_Started__c
  invalid_opp_products_count      NUMERIC(18,0),                         -- Invalid_Opportunity_Products_Count__c
  current_stage_pending_count     NUMERIC(18,0),                         -- CurrentStagePendingCount__c
  lastmodified_hour               NUMERIC(18,0),                         -- LastmodifiedHour__c
  process_trace_id                NUMERIC(18,0),                         -- ProcessTraceId__c
  total_percentage                NUMERIC(18,2),                         -- TotalPercentage__c
  connect_qualified_value         NUMERIC(18,0),                         -- Connect_Qualified__c (dup)
  fiscal                          VARCHAR(6),                            -- Fiscal
  fiscal_quarter                  INTEGER,                               -- FiscalQuarter
  fiscal_year                     INTEGER,                               -- FiscalYear

  -- ── Status / sentiment ────────────────────────────────────
  renewal_sentiment               crm.opp_renewal_sentiment,             -- RenewalSentiment__c
  onboarding_sentiment            crm.opp_onboarding_sentiment,          -- OnboardingSentiment__c
  account_validation_status       crm.opp_account_validation_status,     -- Account_Validation_Status__c
  ast_status                      crm.opp_ast_status,                    -- ASTStatus__c
  last_signing_status             crm.opp_last_signing_status,           -- LastSigningStatus__c
  transfer_status_abt             crm.opp_transfer_status_abt,           -- TransferStatusABT__c
  legal_involved                  crm.opp_legal_involved,                -- LegalInvolved__c
  procurement_involved            crm.opp_procurement_involved,          -- ProcurementInvolved__c
  discovery_completed             BOOLEAN NOT NULL DEFAULT FALSE,         -- Discovery_Completed__c
  budget_confirmed                BOOLEAN NOT NULL DEFAULT FALSE,         -- Budget_Confirmed__c
  roi_analysis_completed          BOOLEAN NOT NULL DEFAULT FALSE,         -- ROI_Analysis_Completed__c
  offer_attached                  BOOLEAN NOT NULL DEFAULT FALSE,         -- OfferAttached__c
  ready_for_contract_creation     BOOLEAN NOT NULL DEFAULT FALSE,         -- ReadyForContractCreation__c
  has_signed_contract_uploaded    BOOLEAN NOT NULL DEFAULT FALSE,         -- HasSignedContractUploaded__c
  has_open_activity               BOOLEAN NOT NULL DEFAULT FALSE,         -- HasOpenActivity
  has_opportunity_line_item       BOOLEAN NOT NULL DEFAULT FALSE,         -- HasOpportunityLineItem
  has_overdue_task                BOOLEAN NOT NULL DEFAULT FALSE,         -- HasOverdueTask
  has_invalid_product             BOOLEAN NOT NULL DEFAULT FALSE,         -- Has_Invalid_Product__c
  has_errors                      BOOLEAN NOT NULL DEFAULT FALSE,         -- hasErrors__c
  allow_stage_change              BOOLEAN NOT NULL DEFAULT FALSE,         -- AllowStageChange__c
  is_split                        BOOLEAN NOT NULL DEFAULT FALSE,         -- IsSplit
  commission_split                BOOLEAN NOT NULL DEFAULT FALSE,         -- CommissionSplit__c
  is_trial                        BOOLEAN NOT NULL DEFAULT FALSE,         -- IsTrial__c
  is_win_back                     BOOLEAN NOT NULL DEFAULT FALSE,         -- IsWinBack__c
  is_global                       BOOLEAN NOT NULL DEFAULT FALSE,         -- IsGlobal__c
  is_auto_renewal_flag            BOOLEAN NOT NULL DEFAULT FALSE,         -- IsAutoRenewal__c (dup)
  is_created_automatically        BOOLEAN NOT NULL DEFAULT FALSE,         -- IsCreatedAutomatically__c
  abt_failed_case                 BOOLEAN NOT NULL DEFAULT FALSE,         -- ABT_Failed_Case__c
  account_validated               BOOLEAN NOT NULL DEFAULT FALSE,         -- AccountValidated__c
  ebr_override_flag               BOOLEAN NOT NULL DEFAULT FALSE,         -- EBROverrideFlag__c
  first_level_approved_flag       BOOLEAN NOT NULL DEFAULT FALSE,         -- FirstLevelApproved__c
  is_invalid_negotiation_stage    BOOLEAN NOT NULL DEFAULT FALSE,         -- IsInvalidNegotiationStageChange__c
  my_opportunity                  BOOLEAN NOT NULL DEFAULT FALSE,         -- MyOpportunity__c
  revenue_splits_missing_csm      BOOLEAN NOT NULL DEFAULT FALSE,         -- RevenueSplitsMissingCSManager__c
  synced_via_gtw                  BOOLEAN NOT NULL DEFAULT FALSE,         -- SyncedViaGTW__c
  unsubscribed                    BOOLEAN NOT NULL DEFAULT FALSE,         -- Unsubscribed__c
  created_opportunity_via_outlook BOOLEAN NOT NULL DEFAULT FALSE,         -- CreatedOpportunityViaOutlook__c

  -- ── Renewal / contract units ──────────────────────────────
  renewal_contract_units          VARCHAR(4099),                         -- RenewalContractUnits__c (multipicklist)
  renewal_commercial_type         VARCHAR(1300),                         -- RenewalCommercialType__c
  renewal_contract_type           VARCHAR(1300),                         -- RenewalContractType__c
  renewal_lifecycle_type          VARCHAR(1300),                         -- RenewalLifecycleType__c
  sales_channel                   VARCHAR(4099),                         -- SalesChannel__c (multipicklist)
  non_relevant_roles              VARCHAR(4099),                         -- NonRelevantRoles__c (multipicklist)

  -- ── Formula / formula-like text fields ────────────────────
  account_formula                 VARCHAR(1300),                         -- Account__c
  account_country                 VARCHAR(1300),                         -- AccountCountry__c
  account_number_of_employees     VARCHAR(1300),                         -- AccountNumberOfEmployees__c
  contract_formula                VARCHAR(1300),                         -- Contract__c
  current_stage_completion        VARCHAR(1300),                         -- CurrentStageCompletion__c
  current_stage_pending_criteria  VARCHAR(1300),                         -- CurrentStagePendingCriteria__c
  currency_locale                 VARCHAR(1300),                         -- Currency_Locale_c__c
  date_locale                     VARCHAR(1300),                         -- Date_Locale_c__c
  department                      VARCHAR(255),                          -- Department__c
  doc_xpert_account_name          VARCHAR(1300),                         -- DocXpertAccountName__c
  final_offer_document_id         VARCHAR(18),                           -- FinalOfferDocumentId__c
  future_service_level            VARCHAR(255),                          -- FutureServiceLevel__c
  liable_office_text              VARCHAR(1300),                         -- Liable_Office__c
  latest_content_doc_version_id   VARCHAR(18),                           -- LatestContentDocumentVersionId__c
  linkedin_company_id             VARCHAR(80),                           -- LID__LinkedIn_Company_Id__c
  offer_number                    VARCHAR(1300),                         -- OfferNumber__c
  open_risk_summary               TEXT,                                  -- OpenRiskSummary__c (131072)
  opportunity_owner_name          VARCHAR(1300),                         -- OpportunityOwnerName__c
  outreach_last_touch_sequence    VARCHAR(255),                          -- Outreach_Last_Touch_Sequence__c
  outreach_sequence_attributed    VARCHAR(1300),                         -- Outreach_Sequence_Attributed__c
  outreach_attributed_sequences   TEXT,                                  -- Outreach_Attributed_Finished_Sequences__c (30000)
  owner_manager                   VARCHAR(1300),                         -- Owner_Manager__c
  owner_profit_center             VARCHAR(1300),                         -- OwnerProfitCenter__c
  parent_account_id_formula       VARCHAR(1300),                         -- ParentAccountID__c
  path_to_purchase                TEXT,                                  -- PathToPurchase__c (32768)
  payment_split                   TEXT,                                  -- PaymentSplit__c (32768)
  previous_stage_history          TEXT,                                  -- PreviousStageHistory__c (32768)
  pricebook_name                  VARCHAR(1300),                         -- PriceBook_Name__c
  primary_contact_name            VARCHAR(1300),                         -- Primary_Contact_Name__c
  primary_contact_phone           VARCHAR(1300),                         -- Primary_Contact_Phone_Formula__c
  processing_errors               VARCHAR(5000),                         -- ProcessingErrors__c
  profit_center_text              VARCHAR(1300),                         -- Profit_Center_c__c
  qualified_by                    VARCHAR(255),                          -- Qualified_by__c
  qualified_by_role               VARCHAR(255),                          -- Qualified_by_Role__c
  risk_status                     VARCHAR(1300),                         -- RiskStatus__c
  sales_manager_id                VARCHAR(80),                           -- SalesManagerID__c
  sales_team_text_formula         VARCHAR(1300),                         -- Sales_Team__c
  service_level                   VARCHAR(1300),                         -- ServiceLevel__c
  signed_contract_document_id     VARCHAR(18),                           -- SignedContractDocumentId__c
  source_contract_end_date_us     VARCHAR(1300),                         -- SourceContractEndDate_US__c
  source_offer_number             VARCHAR(60),                           -- SourceOfferNumber__c
  tier                            VARCHAR(60),                           -- Tier__c
  today_eu                        VARCHAR(1300),                         -- Today_EU__c
  today_us                        VARCHAR(1300),                         -- Today_US__c
  today_eu_short                  VARCHAR(1300),                         -- TodayEUshort__c
  today_us_short                  VARCHAR(1300),                         -- TodayUSshort__c
  utm_parameter                   VARCHAR(255),                          -- UTMParameter__c
  xactly_payout_status            VARCHAR(50),                           -- XactlyPayoutStatus__c
  quote_validity_date_us          VARCHAR(1300),                         -- QuoteValidityDate_US__c
  converted_from_lead_id          VARCHAR(255),                          -- ConvertedFromLeadId__c
  backend_user_id                 VARCHAR(25),                           -- BackendUserID__c

  -- ── Soft delete / audit ───────────────────────────────────
  is_deleted                      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at                      TIMESTAMPTZ,
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Self-referential opportunity FK ──────────────────────────
ALTER TABLE crm.opportunity
  ADD CONSTRAINT fk_opp_source FOREIGN KEY (source_opportunity_id) REFERENCES crm.opportunity(id);

-- ── updated_at trigger ────────────────────────────────────────
CREATE TRIGGER trg_opportunity_updated
  BEFORE UPDATE ON crm.opportunity
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ── RLS ───────────────────────────────────────────────────────
ALTER TABLE crm.opportunity ENABLE ROW LEVEL SECURITY;
CREATE POLICY opportunity_isolation ON crm.opportunity
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- ── Audit trigger ─────────────────────────────────────────────
CREATE TRIGGER trg_audit_opportunity
  AFTER INSERT OR UPDATE OR DELETE ON crm.opportunity
  FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger();

-- ── Recreate opportunity_contact_role ─────────────────────────
CREATE TABLE crm.opportunity_contact_role (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES crm.tenant(id),
  opportunity_id  UUID NOT NULL REFERENCES crm.opportunity(id),
  contact_id      UUID NOT NULL REFERENCES crm.contact(id),
  role            crm.contact_role,
  is_primary      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, opportunity_id, contact_id)
);
ALTER TABLE crm.opportunity_contact_role ENABLE ROW LEVEL SECURITY;
CREATE POLICY ocr_isolation ON crm.opportunity_contact_role
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);
CREATE TRIGGER trg_ocr_updated BEFORE UPDATE ON crm.opportunity_contact_role
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX idx_opp_tenant           ON crm.opportunity (tenant_id);
CREATE INDEX idx_opp_account          ON crm.opportunity (tenant_id, account_id);
CREATE INDEX idx_opp_owner            ON crm.opportunity (tenant_id, owner_id);
CREATE INDEX idx_opp_stage            ON crm.opportunity (tenant_id, stage_name);
CREATE INDEX idx_opp_close_date       ON crm.opportunity (tenant_id, close_date);
CREATE INDEX idx_opp_forecast         ON crm.opportunity (tenant_id, forecast_category);
CREATE INDEX idx_opp_type             ON crm.opportunity (tenant_id, type);
CREATE INDEX idx_opp_profit_center    ON crm.opportunity (tenant_id, profit_center);
CREATE INDEX idx_opp_platform         ON crm.opportunity (tenant_id, platform);
CREATE INDEX idx_opp_primary_product  ON crm.opportunity (tenant_id, primary_product);
CREATE INDEX idx_opp_arr              ON crm.opportunity (tenant_id, annual_recurring_revenue DESC)
  WHERE is_deleted = FALSE;
CREATE INDEX idx_opp_open_pipeline    ON crm.opportunity (tenant_id, close_date, amount)
  WHERE is_closed = FALSE AND is_deleted = FALSE;
CREATE INDEX idx_opp_won              ON crm.opportunity (tenant_id, close_date)
  WHERE is_won = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_opp_renewal          ON crm.opportunity (tenant_id, type)
  WHERE type = 'RENEWAL' AND is_deleted = FALSE;
CREATE INDEX idx_opp_created          ON crm.opportunity (tenant_id, created_at DESC);
CREATE INDEX idx_opp_not_deleted      ON crm.opportunity (tenant_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_opp_name_trgm        ON crm.opportunity USING GIN (name gin_trgm_ops);
CREATE INDEX idx_opp_csm              ON crm.opportunity (tenant_id, client_success_manager_id);
CREATE INDEX idx_opp_sales_rep        ON crm.opportunity (tenant_id, sales_representative_id);
CREATE INDEX idx_opp_approval_status  ON crm.opportunity (tenant_id, approval_status)
  WHERE approval_needed = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_opp_renewal_sent     ON crm.opportunity (tenant_id, renewal_sentiment)
  WHERE is_deleted = FALSE;
CREATE INDEX idx_ocr_opportunity      ON crm.opportunity_contact_role (tenant_id, opportunity_id);
CREATE INDEX idx_ocr_contact          ON crm.opportunity_contact_role (tenant_id, contact_id);
