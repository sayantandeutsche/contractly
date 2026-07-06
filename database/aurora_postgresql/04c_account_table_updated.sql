-- =============================================================
-- 04c_account_table_updated.sql
-- Drop and recreate crm.account based on actual Salesforce
-- Account field definitions from apex log
-- Run as: crm_admin
-- NOTE: Run AFTER 03_schema_and_enums.sql and 02_extensions_and_roles.sql
-- =============================================================

SET search_path = crm, public;

-- ── Drop dependent objects first ─────────────────────────────
DROP TABLE IF EXISTS crm.opportunity_contact_role CASCADE;
DROP TABLE IF EXISTS crm.opportunity              CASCADE;
DROP TABLE IF EXISTS crm.contact                  CASCADE;
DROP TABLE IF EXISTS crm.contract                 CASCADE;
DROP TABLE IF EXISTS crm.account                  CASCADE;

-- ── Drop old account-related enums ───────────────────────────
DROP TYPE IF EXISTS crm.account_type      CASCADE;
DROP TYPE IF EXISTS crm.account_industry  CASCADE;
DROP TYPE IF EXISTS crm.account_ownership CASCADE;

-- ══════════════════════════════════════════════════════════════
-- ENUMS — derived from actual Salesforce picklist values
-- ══════════════════════════════════════════════════════════════

-- Account Type (from Type field)
CREATE TYPE crm.account_type AS ENUM (
    'Competitor (Banned)',
    'OFAC (Restricted)',
    'Master Service Agreement (MSA)',
    'Global Testballoon',
    'Global Deal'
);

-- Industry (shared with Lead)
CREATE TYPE crm.account_industry AS ENUM (
    'OTHER', 'AGENCIES', 'AUTOMOTIVE', 'CHEMICALS', 'CONSULTING',
    'CONSUMER_GOODS', 'E_COMMERCE', 'EDUCATION', 'ENERGY',
    'ENTERTAINMENT___EVENT', 'FINANCIAL_SERVICES___INSURANCE',
    'FOOD___BEVERAGE', 'GOVERNMENT___PUBLIC', 'LEGAL', 'MANUFACTURING',
    'MARKET_RESEARCH', 'MEDIA___PUBLISHING', 'NGO', 'PHARMA___HEALTH',
    'TELECOMMUNICATION___IT', 'TOURISM___LEISURE',
    'TRANSPORTATION___LOGISTICS', 'UTILITY_SERVICES'
);

-- Ownership
CREATE TYPE crm.account_ownership AS ENUM (
    'Public', 'Private', 'Subsidiary', 'Other'
);

-- Account-specific enums
CREATE TYPE crm.account_lead_source AS ENUM (
    'Academia Availability Request', 'Andzup', 'Apollo', 'Chrunchbase',
    'Clay', 'Client Service', 'Cold Call', 'Cold Mailing', 'Customer Visit',
    'Inbound', 'Linkedin', 'LinkedIn Lead Gen', 'Mailchimp', 'Other',
    'Outbound', 'Partnership', 'Pendo', 'Reference', 'Salesviewer',
    'Seamless.AI', 'Webform', 'Webinar', 'Whitepaper', 'Winmo',
    'Yesware', 'Zoominfo'
);

CREATE TYPE crm.account_category AS ENUM (
    'Inbound', 'Outbound'
);

CREATE TYPE crm.account_currency_iso AS ENUM (
    'AUD', 'GBP', 'EUR', 'INR', 'JPY', 'SGD', 'USD'
);

CREATE TYPE crm.account_customer_status AS ENUM (
    'Prospect', 'Client', 'Ex-Client', 'Indirect Prospect',
    'Indirect Client', 'None - Client', 'New Customer',
    'Paid Customer', 'Competitor'
);

CREATE TYPE crm.account_customer_category AS ENUM (
    'Standard', 'Premium', 'Growth', 'Tech'
);

CREATE TYPE crm.account_segment AS ENUM (
    'Academia', 'Base', 'Scale', 'Key', 'Named'
);

CREATE TYPE crm.account_healthscore AS ENUM (
    'Neutral', 'Critical', 'Unhealthy', 'Healthy', 'Superstar'
);

CREATE TYPE crm.account_profit_center AS ENUM (
    'US', 'Asia', 'EMEA', 'CE'
);

CREATE TYPE crm.account_platform AS ENUM (
    'English', 'German', 'French', 'Spanish', 'EcommerceDB'
);

CREATE TYPE crm.account_platforms AS ENUM (
    'Arriba', 'Coupa', 'Tungsten', 'Others'
);

CREATE TYPE crm.account_sub_industry AS ENUM (
    'University', 'Library', 'School'
);

CREATE TYPE crm.account_subscription_status AS ENUM (
    'former subscriber', 'free subscriber', 'non-subscriber',
    'subscriber', 'write-off'
);

CREATE TYPE crm.account_expiration_agreement AS ENUM (
    'Time-Based usage', 'Tied to Client relationship', 'No expiration'
);

CREATE TYPE crm.account_merge AS ENUM (
    'Merge', 'Don''t Merge'
);

CREATE TYPE crm.account_tax_exemption AS ENUM (
    'Tax Exempt', 'Not Applicable'
);

CREATE TYPE crm.account_withholding_tax AS ENUM (
    'Withholding Tax', 'Not Applicable'
);

CREATE TYPE crm.account_usage_rights AS ENUM (
    'Logo', 'Success Story', 'Statement', 'Usage not wished'
);

CREATE TYPE crm.account_number_of_employees AS ENUM (
    '1-10', '11-50', '51-200', '201-500', '501-1000',
    '1001-5000', '5.001-10.000', '10.001-30.000', '>30.000', 'Unknown'
);

CREATE TYPE crm.account_number_registered_users AS ENUM (
    '0 - 9', '10 - 19', '20 - 49', '50 - 99', '100 - 199'
);

CREATE TYPE crm.account_geocode_accuracy AS ENUM (
    'Address', 'NearAddress', 'Block', 'Street', 'ExtendedZip',
    'Zip', 'Neighborhood', 'City', 'County', 'State', 'Unknown'
);

CREATE TYPE crm.account_fte_size AS ENUM (
    '>= 1000', '1001 - 2500', '2501 - 5000', '5001 - 7500',
    '7501 - 10000', '10001 - 15000', '15001 - 20000', '20001 - 25000',
    '25001 - 30000', '30001 - 35000', '35001 - 40000', '40001 +',
    '0 - 1000', '1001 - 3000', '3001 - 6000', '6001 - 10000',
    '10001 - 30000', '30001 - 50000', '50001 - 75000',
    '75001 - 100000', '100001 - 150000', '150001 - 200000',
    '200001 - 300000', '300001 - 500000', '500001 - 850000',
    '850001 - 1100000', '1100001 +'
);

CREATE TYPE crm.account_license_type AS ENUM (
    'SINGLE_ACCOUNT', 'CORPORATE_ACCOUNT', 'CORPORATE_ACCOUNT_LIGHT',
    'CAMPUS_LICENSE', 'CAMPUS_LICENSE_LIGHT', 'CAMPUS_LICENSE_INT',
    'ENTERPRISE_ACCOUNT', 'STUDENT_ACCOUNT', 'BASIC_ACCOUNT_PLUS',
    'BASIC_ACCOUNT', 'CORPORATE_ACCOUNT_CHURNER', 'PREMIUM_ACCOUNT',
    'NONE', 'PROJECT_ACCOUNT'
);

CREATE TYPE crm.account_account_type_custom AS ENUM (
    'EMPLOYEE_ACCOUNT', 'GROUP_ACCOUNT', 'SINGLE_ACCOUNT'
);

CREATE TYPE crm.account_paid_accounts AS ENUM (
    'Yes', 'No'
);

CREATE TYPE crm.account_strategic_potential AS ENUM (
    'Yes', 'No'
);

CREATE TYPE crm.account_rating AS ENUM (
    'Hot', 'Warm', 'Cold'
);

-- ══════════════════════════════════════════════════════════════
-- ACCOUNT TABLE
-- ══════════════════════════════════════════════════════════════
CREATE TABLE crm.account (

  -- ── Core / system ─────────────────────────────────────────
  id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                       UUID NOT NULL REFERENCES crm.tenant(id),
  owner_id                        UUID REFERENCES crm.app_user(id),
  created_by_id                   UUID REFERENCES crm.app_user(id),
  last_modified_by_id             UUID REFERENCES crm.app_user(id),
  parent_id                       UUID,                          -- ParentId (self-ref, FK added below)
  master_record_id                UUID,                          -- MasterRecordId

  -- ── Identity ──────────────────────────────────────────────
  name                            VARCHAR(255) NOT NULL,         -- Name
  account_number                  VARCHAR(40),                   -- AccountNumber
  account_name_formula            VARCHAR(1300),                 -- AccountName__c
  account_18char_id               VARCHAR(1300),                 -- Account18CharacterId__c
  site                            VARCHAR(80),                   -- Site (Account Site)
  ticker_symbol                   VARCHAR(20),                   -- TickerSymbol
  sic                             VARCHAR(20),                   -- Sic
  sic_desc                        VARCHAR(80),                   -- SicDesc
  naics_code                      VARCHAR(20),
  source_system_identifier        VARCHAR(85),                   -- SourceSystemIdentifier

  -- ── Classification ────────────────────────────────────────
  type                            crm.account_type,              -- Type
  account_type_custom             crm.account_account_type_custom, -- AccountType__c
  industry                        crm.account_industry,          -- Industry
  sub_industry                    crm.account_sub_industry,      -- Sub_Industry__c
  industry_type_default           VARCHAR(1300),                 -- IndustryTypeDefault__c
  is_industry_type_editable       BOOLEAN NOT NULL DEFAULT FALSE, -- IsIndustryTypeEditable__c
  ownership                       crm.account_ownership,         -- Ownership
  rating                          crm.account_rating,            -- Rating
  account_source                  crm.account_lead_source,       -- AccountSource
  account_category                crm.account_category,          -- Account_Category__c
  segment                         crm.account_segment,           -- Segment__c
  calculated_segment              crm.account_segment,           -- CalculatedSegment__c
  segment_overridden              BOOLEAN NOT NULL DEFAULT FALSE, -- SegmentOverridden__c
  segment_icon                    VARCHAR(1300),                 -- SegmentIcon__c
  profit_center                   crm.account_profit_center,     -- ProfitCenter__c
  platform                        crm.account_platform,          -- Platform__c
  platforms                       crm.account_platforms,         -- Platforms__c
  other_platform                  VARCHAR(255),                  -- OtherPlatform__c
  customer_status                 crm.account_customer_status,   -- CustomerStatus__c
  customer_category               crm.account_customer_category, -- Customer_Category__c
  subscription_status             crm.account_subscription_status, -- SubscriptionStatus__c
  license_type                    VARCHAR(4099),                 -- LicenseType__c (multipicklist)
  strategic_potential             crm.account_strategic_potential, -- StrategicPotential__c
  healthscore                     crm.account_healthscore,       -- Healthscore__c
  paid_accounts_in_company        crm.account_paid_accounts,     -- PaidAccountsInCompany__c
  merge_flag                      crm.account_merge,             -- Merge__c

  -- ── Contact / communication ───────────────────────────────
  phone                           VARCHAR(40),                   -- Phone
  fax                             VARCHAR(40),                   -- Fax
  website                         VARCHAR(255),                  -- Website
  website_domain                  VARCHAR(1300),                 -- Website_Domain__c
  photo_url                       VARCHAR(255),                  -- PhotoUrl
  account_email                   VARCHAR(80),                   -- AccountEmail__c (Billing E-Mail)
  dunning_email                   VARCHAR(80),                   -- Dunning_E_Mail__c
  email_primary_domain            VARCHAR(1300),                 -- Email_Primary_Domain__c
  linkedin_company_id             VARCHAR(80),                   -- LID__LinkedIn_Company_Id__c
  linkedin_advertiser_account     VARCHAR(255),                  -- LinkedInAdvertiserAccount__c
  hidden_email_from_lead          VARCHAR(255),                  -- HiddenEmailFromLead__c

  -- ── Billing address (Sell-To) ─────────────────────────────
  billing_street                  VARCHAR(255),                  -- BillingStreet
  billing_city                    VARCHAR(40),                   -- BillingCity
  billing_state                   VARCHAR(80),                   -- BillingState
  billing_state_code              VARCHAR(10),                   -- BillingStateCode
  billing_postal_code             VARCHAR(20),                   -- BillingPostalCode
  billing_country                 VARCHAR(80),                   -- BillingCountry (Sell-To Country)
  billing_country_code            CHAR(2),                       -- BillingCountryCode
  billing_latitude                NUMERIC(18,15),                -- BillingLatitude
  billing_longitude               NUMERIC(18,15),                -- BillingLongitude
  billing_geocode_accuracy        crm.account_geocode_accuracy,  -- BillingGeocodeAccuracy

  -- ── Shipping address ──────────────────────────────────────
  shipping_street                 VARCHAR(255),                  -- ShippingStreet
  shipping_city                   VARCHAR(40),                   -- ShippingCity
  shipping_state                  VARCHAR(80),                   -- ShippingState
  shipping_state_code             VARCHAR(10),                   -- ShippingStateCode
  shipping_postal_code            VARCHAR(20),                   -- ShippingPostalCode
  shipping_country                VARCHAR(80),                   -- ShippingCountry
  shipping_country_code           CHAR(2),                       -- ShippingCountryCode
  shipping_latitude               NUMERIC(18,15),                -- ShippingLatitude
  shipping_longitude              NUMERIC(18,15),                -- ShippingLongitude
  shipping_geocode_accuracy       crm.account_geocode_accuracy,  -- ShippingGeocodeAccuracy

  -- ── Financial ─────────────────────────────────────────────
  annual_revenue                  NUMERIC(18,0),                 -- AnnualRevenue
  annualized_revenue              NUMERIC(18,0),                 -- AnnualizedRevenue__c (ARR)
  monthly_revenue                 NUMERIC(18,0),                 -- MonthlyRevenue__c (MRR)
  open_risk_amount                NUMERIC(18,2),                 -- OpenRiskAmount__c
  parent_arr                      NUMERIC(18,2),                 -- ParentARR__c
  target_annualized_revenue       NUMERIC(18,0),                 -- TargetAnnualizedRevenue__c
  target_annualized_gap_value     NUMERIC(18,0),                 -- TargetAnnualizedGapValue__c
  target_annualized_gap_percent   NUMERIC(18,2),                 -- TargetAnnualizedGapPercent__c
  currency_iso_code               crm.account_currency_iso NOT NULL DEFAULT 'USD',

  -- ── Employees / size ──────────────────────────────────────
  number_of_employees             INTEGER,                       -- NumberOfEmployees
  number_of_employees_range       crm.account_number_of_employees, -- NumberOfEmployees__c
  number_of_registered_users      crm.account_number_registered_users, -- NumberOfRegisteredUsers__c
  fte_size                        crm.account_fte_size,          -- FTE_Size__c

  -- ── Contract / revenue metrics ────────────────────────────
  activated_contracts             NUMERIC(10,0),                 -- ActivatedContracts__c
  current_contracts               NUMERIC(10,0),                 -- CurrentContracts__c
  past_contracts                  NUMERIC(10,0),                 -- PastContracts__c
  upcoming_contracts              NUMERIC(10,0),                 -- UpcomingContracts__c
  active_opportunities_count      NUMERIC(4,0),                  -- ActiveOpportunitiesCount__c
  number_of_open_opportunities    NUMERIC(18,0),                 -- NumberofopenOpportunities__c
  number_of_opportunities         NUMERIC(18,0),                 -- NumberOfOpportunities__c
  number_of_won_opportunities     NUMERIC(18,0),                 -- NumberofWonOpportunities__c
  open_risk_count                 NUMERIC(18,0),                 -- OpenRiskCount__c
  no_associated_contacts          NUMERIC(18,0),                 -- NoAssociatedContacts__c
  no_associated_leads             NUMERIC(18,0),                 -- NoAssociatedLeads__c
  total_purchased_hours           NUMERIC(18,0),                 -- TotalPurchasedHours__c
  used_hours                      NUMERIC(18,2),                 -- UsedHours__c
  remaining_hours                 NUMERIC(18,2),                 -- RemainingHours__c
  record_count_search_terms       NUMERIC(18,2),                 -- Record_Count_Search_Terms__c
  len_account_name                NUMERIC(18,0),                 -- LENAccountName__c
  len_sell_to_city                NUMERIC(18,0),                 -- LENSellToCity__c
  len_sell_to_street              NUMERIC(18,0),                 -- LENSellToStreet__c

  -- ── Dates ─────────────────────────────────────────────────
  expiration_date                 DATE,                          -- ExpirationDate__c
  expiration_agreement            crm.account_expiration_agreement, -- ExpirationAgreement__c
  last_contract_end_date          DATE,                          -- LastContractEndDate__c
  last_activity_date              DATE,                          -- LastActivityDate
  last_meaningful_connect         DATE,                          -- LastMeaningfulConnect__c
  last_referenced_date            TIMESTAMPTZ,                   -- LastReferencedDate
  last_viewed_date                TIMESTAMPTZ,                   -- LastViewedDate
  clay_last_enrichment            TIMESTAMPTZ,                   -- Clay__Last_Enrichment_By_Clay__c
  enriched_date                   DATE,                          -- EnrichedDate__c
  validation_timestamp            TIMESTAMPTZ,                   -- Validation_Timestamp__c

  -- ── Legal / compliance ────────────────────────────────────
  uid_vat                         VARCHAR(20),                   -- UID_VAT__c
  tax_exemption                   crm.account_tax_exemption,     -- Tax_Exemption__c
  withholding_tax                 crm.account_withholding_tax,   -- Withholding_Tax__c
  usage_rights                    crm.account_usage_rights,      -- UsageRights__c
  usage_rights_multi              VARCHAR(4099),                 -- UsageRights2__c (multipicklist)
  usage_rights_is_active          BOOLEAN NOT NULL DEFAULT FALSE, -- UsageRightsIsActive__c
  submission_via_vendor_portal    BOOLEAN NOT NULL DEFAULT FALSE, -- SubmissionViaVendorPortalRequired__c
  third_party_buyer               BOOLEAN NOT NULL DEFAULT FALSE, -- Third_Party_Buyer__c
  legal_entity_in_account_name    BOOLEAN NOT NULL DEFAULT FALSE, -- LegalEntityInAccountName__c
  legal_entity_toast_test_group   VARCHAR(1300),                 -- LegalEntityToastTestGroup__c
  legal_warning_displayed         BOOLEAN NOT NULL DEFAULT FALSE, -- LegalWarningDisplayed__c

  -- ── ERP / external IDs ────────────────────────────────────
  customer_id                     VARCHAR(30),                   -- CustomerID__c
  debtor_id_erp                   VARCHAR(25),                   -- DebtorIDERP__c (NAV)
  sap_debtor_id                   VARCHAR(25),                   -- SAP_Debtor_Id__c
  sap_country_code                VARCHAR(1300),                 -- SAP_Country_Code__c
  migration_id                    VARCHAR(100),                  -- MigrationId__c
  kl_account_id                   VARCHAR(100),                  -- KLAccountId__c
  sfra_account_id                 VARCHAR(255),                  -- SFRA_Account_Id__c
  jigsaw                          VARCHAR(20),                   -- Jigsaw
  jigsaw_company_id               VARCHAR(20),                   -- JigsawCompanyId
  company_insights_id             VARCHAR(20),                   -- companyInsightsId__c
  insights_url                    VARCHAR(1300),                 -- insightsURL__c
  backend_user_id                 VARCHAR(25),                   -- BackendUserID__c
  backend_user_deleted            BOOLEAN NOT NULL DEFAULT FALSE, -- BackendUserDeleted__c
  channel_program_name            VARCHAR(255),                  -- ChannelProgramName
  channel_program_level_name      VARCHAR(255),                  -- ChannelProgramLevelName
  source_system_id                VARCHAR(85),                   -- SourceSystemIdentifier (dup)

  -- ── Relationships ─────────────────────────────────────────
  calculated_owner_id             UUID,                          -- CalculatedOwner__c
  calculated_primary_csm_id       UUID,                          -- CalculatedPrimaryCSM__c
  client_success_manager_id       UUID,                          -- Client_Success_Manager__c
  sales_representative_id         UUID,                          -- Sales_Representative__c
  dupcheck_ultimate_parent_id     UUID,                          -- dupcheck__dc3UltimateParent__c
  country_ref_id                  UUID,                          -- Country__c (reference)
  account_hierarchy_level         VARCHAR(1300),                 -- AccountHierarchyLevel__c
  highest_parent                  VARCHAR(1300),                 -- HighestParent__c
  parent_account_email            VARCHAR(1300),                 -- ParentAccountEmail__c
  parent_account_name             VARCHAR(1300),                 -- ParentAccountName__c
  top_level_account               BOOLEAN NOT NULL DEFAULT FALSE, -- TopLevelAccount__c
  top_level_account_formula       VARCHAR(1300),                 -- TopLevelAccount_formula__c
  has_parent                      BOOLEAN NOT NULL DEFAULT FALSE, -- HasParent__c

  -- ── Flags / booleans ──────────────────────────────────────
  is_active_subscription          BOOLEAN NOT NULL DEFAULT FALSE, -- IsActiveSubscription__c
  is_customer_id_even             BOOLEAN NOT NULL DEFAULT FALSE, -- IsCustomerIdEven__c
  is_customer_portal              BOOLEAN NOT NULL DEFAULT FALSE, -- IsCustomerPortal
  is_partner                      BOOLEAN NOT NULL DEFAULT FALSE, -- IsPartner
  is_priority_record              BOOLEAN NOT NULL DEFAULT FALSE, -- IsPriorityRecord
  is_kl_outbound                  BOOLEAN NOT NULL DEFAULT FALSE, -- isKLOutbound__c
  churn_risk                      BOOLEAN NOT NULL DEFAULT FALSE, -- Churn_Risk__c
  enriched                        BOOLEAN NOT NULL DEFAULT FALSE, -- Enriched__c
  owner_overridden                BOOLEAN NOT NULL DEFAULT FALSE, -- OwnerOverridden__c
  primary_csm_overridden          BOOLEAN NOT NULL DEFAULT FALSE, -- PrimaryCSMOverridden__c
  validated                       BOOLEAN NOT NULL DEFAULT FALSE, -- Validated__c
  customer_update_flag            BOOLEAN NOT NULL DEFAULT FALSE, -- CustomerUpdateFlag__c
  predefined_filter_crossobject   BOOLEAN NOT NULL DEFAULT FALSE, -- PredefinedFilterCrossObjectDC__c
  dupcheck_disable                BOOLEAN NOT NULL DEFAULT FALSE, -- dupcheck__dc3DisableDuplicateCheck__c
  masteragreement_attached        BOOLEAN NOT NULL DEFAULT FALSE, -- MasteragreementAttached__c

  -- ── Text / notes / descriptions ───────────────────────────
  description                     TEXT,                          -- Description (32000)
  account_description             TEXT,                          -- AccountDescription__c (32768)
  additional_portal_information   TEXT,                          -- AdditionalPortalInformation__c (32768)
  usage_conditions                TEXT,                          -- UsageConditions__c / Notes (32768)
  validation_comments             VARCHAR(255),                  -- Validation_Comments__c
  marketing_material_url          TEXT,                          -- MarketingMaterialURL__c (131072)
  login_information               VARCHAR(255),                  -- LoginInformation__c
  download_masteragreement        VARCHAR(1300),                 -- Download_Masteragreement__c
  masteragreement_content_id      VARCHAR(18),                   -- Masteragreement_ContentID__c
  masteragreement_id              VARCHAR(18),                   -- Masteragreement_ID__c
  account_logo_content_id         VARCHAR(18),                   -- Account_Logo_ContentID__c
  vendor_portal_url               VARCHAR(255),                  -- VendorPortalUrl__c
  record_link                     VARCHAR(1300),                 -- Record_Link__c
  risk_status                     VARCHAR(1300),                 -- RiskStatus__c
  customer                        VARCHAR(1300),                 -- Customer__c
  clearing_house                  VARCHAR(1300),                 -- Clearing_House__c
  search_terms                    VARCHAR(255),                  -- SearchTerms__c
  domain                          VARCHAR(1300),                 -- Domain__c
  sub_domain                      VARCHAR(1300),                 -- Sub_Domain__c
  primary_domain                  VARCHAR(1300),                 -- Primary_Domain__c
  email_domain_merge_exclusion    VARCHAR(1300),                 -- AccountEmailDomainMergeExclusion_2__c
  name_for_duplicatecheck         VARCHAR(1300),                 -- NameForDuplicatecheck__c
  dc_account_name_and_search      VARCHAR(1300),                 -- DCAccountNameAndSearchTerms__c
  dupcheck_index                  TEXT,                          -- dupcheck__dc3Index__c (32768)
  owner_name                      VARCHAR(1300),                 -- Owner_Name__c
  form_suffix                     VARCHAR(1300),                 -- FormSuffix__c
  qualification_guideline         VARCHAR(1300),                 -- used for routing
  selected_company_insights_name  VARCHAR(255),                  -- selectedCompanyInsightsName__c
  selected_company_insights_url   VARCHAR(255),                  -- selectedCompanyInsightsURL__c
  validation_user                 VARCHAR(100),                  -- Validation_User__c

  -- ── Soft delete / audit ───────────────────────────────────
  is_deleted                      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at                      TIMESTAMPTZ,
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Self-referential FK for account hierarchy ─────────────────
ALTER TABLE crm.account
  ADD CONSTRAINT fk_account_parent
  FOREIGN KEY (parent_id) REFERENCES crm.account(id);

-- ── updated_at trigger ────────────────────────────────────────
CREATE TRIGGER trg_account_updated
  BEFORE UPDATE ON crm.account
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ── RLS ───────────────────────────────────────────────────────
ALTER TABLE crm.account ENABLE ROW LEVEL SECURITY;
CREATE POLICY account_isolation ON crm.account
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- ── Audit trigger ─────────────────────────────────────────────
CREATE TRIGGER trg_audit_account
  AFTER INSERT OR UPDATE OR DELETE ON crm.account
  FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger();

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX idx_account_tenant           ON crm.account (tenant_id);
CREATE INDEX idx_account_owner            ON crm.account (tenant_id, owner_id);
CREATE INDEX idx_account_name_trgm        ON crm.account USING GIN (name gin_trgm_ops);
CREATE INDEX idx_account_type             ON crm.account (tenant_id, type);
CREATE INDEX idx_account_industry         ON crm.account (tenant_id, industry);
CREATE INDEX idx_account_parent           ON crm.account (tenant_id, parent_id);
CREATE INDEX idx_account_created          ON crm.account (tenant_id, created_at DESC);
CREATE INDEX idx_account_not_deleted      ON crm.account (tenant_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_account_customer_status  ON crm.account (tenant_id, customer_status);
CREATE INDEX idx_account_segment          ON crm.account (tenant_id, segment);
CREATE INDEX idx_account_profit_center    ON crm.account (tenant_id, profit_center);
CREATE INDEX idx_account_subscription     ON crm.account (tenant_id, subscription_status);
CREATE INDEX idx_account_billing_country  ON crm.account (tenant_id, billing_country);
CREATE INDEX idx_account_billing_country_code ON crm.account (tenant_id, billing_country_code);
CREATE INDEX idx_account_arr              ON crm.account (tenant_id, annualized_revenue DESC)
  WHERE is_deleted = FALSE;
CREATE INDEX idx_account_active_sub       ON crm.account (tenant_id)
  WHERE is_active_subscription = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_account_churn_risk       ON crm.account (tenant_id)
  WHERE churn_risk = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_account_customer_id      ON crm.account (tenant_id, customer_id);
CREATE INDEX idx_account_domain           ON crm.account (tenant_id, domain);
CREATE INDEX idx_account_csm              ON crm.account (tenant_id, client_success_manager_id);
CREATE INDEX idx_account_sales_rep        ON crm.account (tenant_id, sales_representative_id);
