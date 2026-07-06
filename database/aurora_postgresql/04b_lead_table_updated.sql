-- =============================================================
-- 04b_lead_table_updated.sql
-- Drop and recreate crm.lead based on actual Salesforce Lead
-- field definitions from object_fields.log
-- Run as: crm_admin
-- =============================================================

SET search_path = crm, public;

-- ── Drop existing lead table (cascades to RLS, triggers, indexes)
DROP TABLE IF EXISTS crm.lead CASCADE;

-- ── Drop old enums that will be replaced ─────────────────────
DROP TYPE IF EXISTS crm.lead_status      CASCADE;
DROP TYPE IF EXISTS crm.lead_source      CASCADE;
DROP TYPE IF EXISTS crm.salutation       CASCADE;
DROP TYPE IF EXISTS crm.rating           CASCADE;

-- ── New enums from actual Salesforce picklist values ─────────

CREATE TYPE crm.lead_status AS ENUM (
    'Unqualified', 'New', 'MQL', 'Screening',
    'Qualification', 'Outreach', 'Converted'
);

CREATE TYPE crm.lead_source AS ENUM (
    'Academia Availability Request', 'Andzup', 'Apollo', 'Chrunchbase',
    'Clay', 'Client Service', 'Cold Call', 'Cold Mailing', 'Customer Visit',
    'Inbound', 'Linkedin', 'LinkedIn Lead Gen', 'Mailchimp', 'Other',
    'Outbound', 'Partnership', 'Pendo', 'Reference', 'Salesviewer',
    'Seamless.AI', 'Webform', 'Webinar', 'Whitepaper', 'Winmo',
    'Yesware', 'Zoominfo'
);

CREATE TYPE crm.salutation AS ENUM (
    'MR_', 'MRS_', 'MX_', 'Herr', 'Frau'
);

CREATE TYPE crm.rating AS ENUM (
    'Hot', 'Warm', 'Cold'
);

CREATE TYPE crm.lead_academic_title AS ENUM (
    'Dr.', 'Prof.', 'Prof. Dr', 'Mag.'
);

CREATE TYPE crm.lead_academic_status AS ENUM (
    'Student', 'Graduate'
);

CREATE TYPE crm.lead_account_type AS ENUM (
    'EMPLOYEE_ACCOUNT', 'GROUP_ACCOUNT', 'SINGLE_ACCOUNT'
);

CREATE TYPE crm.lead_currency_iso AS ENUM (
    'AUD', 'GBP', 'EUR', 'INR', 'JPY', 'SGD', 'USD'
);

CREATE TYPE crm.lead_department AS ENUM (
    'Executive & Leadership', 'Strategy & Business Development',
    'Marketing & Growth', 'Sales & Revenue Operations',
    'Business Intelligence & Analytics', 'Research & Insights',
    'Product Management', 'Finance & Accounting', 'Operations',
    'Technology & Engineering', 'Communications & PR',
    'Education & Training', 'HR', 'Legal & Compliance', 'Other'
);

CREATE TYPE crm.lead_gender_identity AS ENUM (
    'Male', 'Female', 'Nonbinary', 'Not Listed'
);

CREATE TYPE crm.lead_industry AS ENUM (
    'OTHER', 'AGENCIES', 'AUTOMOTIVE', 'CHEMICALS', 'CONSULTING',
    'CONSUMER_GOODS', 'E_COMMERCE', 'EDUCATION', 'ENERGY',
    'ENTERTAINMENT___EVENT', 'FINANCIAL_SERVICES___INSURANCE',
    'FOOD___BEVERAGE', 'GOVERNMENT___PUBLIC', 'LEGAL', 'MANUFACTURING',
    'MARKET_RESEARCH', 'MEDIA___PUBLISHING', 'NGO', 'PHARMA___HEALTH',
    'TELECOMMUNICATION___IT', 'TOURISM___LEISURE',
    'TRANSPORTATION___LOGISTICS', 'UTILITY_SERVICES'
);

CREATE TYPE crm.lead_category AS ENUM (
    'Inbound', 'Outbound'
);

CREATE TYPE crm.lead_role AS ENUM (
    'User Buyer', 'Economic Buyer', 'Saboteur', 'Coach',
    'Technical Buyer', 'Billing Contact'
);

CREATE TYPE crm.lead_status_cdp AS ENUM (
    'MQL', 'SQL', 'Lead'
);

CREATE TYPE crm.lead_number_of_employees AS ENUM (
    '1-10', '11-50', '51-200', '201-500', '501-1000',
    '1001-5000', '5.001-10.000', '10.001-30.000', '>30.000', 'Unknown'
);

CREATE TYPE crm.lead_number_registered_users AS ENUM (
    '0 - 9', '10 - 19', '20 - 49', '50 - 99', '100 - 199'
);

CREATE TYPE crm.lead_platform AS ENUM (
    'English', 'German', 'French', 'Spanish', 'EcommerceDB'
);

CREATE TYPE crm.lead_profit_center AS ENUM (
    'US', 'Asia', 'EMEA', 'CE'
);

CREATE TYPE crm.lead_pronouns AS ENUM (
    'He/Him', 'She/Her', 'They/Them', 'He/They', 'She/They', 'Not Listed'
);

CREATE TYPE crm.lead_revenue_range AS ENUM (
    '< 10.000', '10.000 - 50.000', '50.000 - 250.000',
    '250.000 - 500.000', '> 500.000'
);

CREATE TYPE crm.lead_role_level AS ENUM (
    'Student', 'Team Member', 'Manager', 'Director / VP',
    'C-Level / Owner', 'External / Consultant'
);

CREATE TYPE crm.lead_subscription_status AS ENUM (
    'former subscriber', 'free subscriber', 'non-subscriber',
    'subscriber', 'write-off'
);

CREATE TYPE crm.lead_unqualify_reason AS ENUM (
    'Company No Potential', 'Competitor', 'Country Restricted',
    'Customer Not Interested', 'Deletion Request', 'Existing Domain Access',
    'Insufficient Information', 'Opt-out', 'Person No Potential',
    'Private email', 'Spam', 'Student', 'System Unqualified', 'Clean up',
    'Unresponsive', 'ICP Mismatch (Too Small / Wrong Industry)',
    'No Use Case Identified', 'Valid Use Case – Not Supported Yet',
    'No Budget / Not a Priority', 'No Authority / Not a Decision Maker',
    'Wrong Timing (Too Early Stage / Locked in Contract)',
    'Chose Competitor', 'Unresponsive / Not a Real Prospect', 'Legal'
);

CREATE TYPE crm.lead_geocode_accuracy AS ENUM (
    'Address', 'NearAddress', 'Block', 'Street', 'ExtendedZip',
    'Zip', 'Neighborhood', 'City', 'County', 'State', 'Unknown'
);

CREATE TYPE crm.lead_cadence_action AS ENUM (
    'Removed – Commercial Opt-Out', 'Removed – Unqualified'
);

CREATE TYPE crm.lead_product_of_interest AS ENUM (
    'None', 'ASK_STATISTA', 'BASIC_ACCOUNT', 'BASIC_ACCOUNT_PLUS',
    'CAMPUS_LICENSE_INT', 'COMPANY_DATABASE', 'CORPORATE_ACCOUNT',
    'DOSSIER', 'ECOMMERCE_DB', 'ENTERPRISE_ACCOUNT',
    'GLOBAL_CONSUMER_SURVEY', 'PPT_CUSTOMIZATION', 'PROJECT_ACCOUNT',
    'SINGLE_ACCOUNT', 'SINGLE_ACCOUNT_TEST', 'WEBINAR', 'LICENSE_PRICING',
    'LOGIN_ACCESS', 'OTHER', 'PERSONAL_ACCOUNT', 'PROFESSIONAL_ACCOUNT',
    'BUSINESS_SUITE', 'COMPANY_INSIGHTS', 'CONSUMER_INSIGHTS',
    'ECOMMERCE_INSIGHTS', 'STARTER_ACCOUNT', 'STARTER_ACCOUNT_TEST', 'API'
);

CREATE TYPE crm.lead_gtw_channel AS ENUM (
    'Email', 'Instagram', 'LinkedIn', 'Facebook',
    'Recommendation', 'Statista Website', 'Other'
);

-- ═══════════════════════════════════════════════════════════
-- LEAD TABLE — full Salesforce field parity
-- ═══════════════════════════════════════════════════════════
CREATE TABLE crm.lead (

  -- ── Core / system ────────────────────────────────────────
  id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                       UUID NOT NULL REFERENCES crm.tenant(id),
  owner_id                        UUID REFERENCES crm.app_user(id),
  created_by_id                   UUID REFERENCES crm.app_user(id),
  last_modified_by_id             UUID REFERENCES crm.app_user(id),

  -- ── Identity ─────────────────────────────────────────────
  salutation                      crm.salutation,
  first_name                      VARCHAR(40),
  last_name                       VARCHAR(80)           NOT NULL,
  name                            VARCHAR(121) GENERATED ALWAYS AS (
                                    COALESCE(first_name || ' ', '') || last_name
                                  ) STORED,
  title                           VARCHAR(128),                   -- Job Title
  academic_title                  crm.lead_academic_title,        -- Academic_Title__c
  pronouns                        crm.lead_pronouns,              -- Pronouns
  gender_identity                 crm.lead_gender_identity,       -- GenderIdentity
  gender                          VARCHAR(1300),                  -- Gender__c (free text)

  -- ── Company ───────────────────────────────────────────────
  company                         VARCHAR(255)          NOT NULL,
  company_research                TEXT,                           -- Company_Research__c (32768)
  company_for_duplicatecheck      VARCHAR(1300),                  -- CompanyForDuplicatecheck__c
  company_insights_id             VARCHAR(20),                    -- companyInsightsId__c
  account_type                    crm.lead_account_type,          -- AccountType__c
  associated_account_id           UUID,                           -- AssociatedAccount__c (ref)

  -- ── Contact info ─────────────────────────────────────────
  email                           VARCHAR(80),
  email_2                         VARCHAR(80),                    -- Email_2__c (LinkedInWorkEmail)
  email_for_duplicatecheck        VARCHAR(1300),                  -- EmailforDuplicatecheck__c
  email_domain_filter_status      VARCHAR(1300),                  -- EmailDomainFilterStatus__c
  email_dupe_frequent_words       VARCHAR(1300),                  -- EmailDupeFrequentWords__c
  email_bounced_date              TIMESTAMPTZ,
  email_bounced_reason            VARCHAR(255),
  has_opted_out_of_email          BOOLEAN NOT NULL DEFAULT FALSE,
  has_opted_out_of_fax            BOOLEAN NOT NULL DEFAULT FALSE,
  email_activation                BOOLEAN NOT NULL DEFAULT FALSE, -- EmailActivation__c
  email_domain_filter             BOOLEAN NOT NULL DEFAULT FALSE, -- EmailDomainFilter__c
  academic_email_domain_filter    BOOLEAN NOT NULL DEFAULT FALSE, -- AcademicEmailDomainFilter__c
  private_email_domain_filter     BOOLEAN NOT NULL DEFAULT FALSE, -- PrivateEmailDomainFilter__c
  phone                           VARCHAR(40),
  mobile_phone                    VARCHAR(40),
  fax                             VARCHAR(40),
  do_not_call                     BOOLEAN NOT NULL DEFAULT FALSE,
  do_not_contact                  BOOLEAN NOT NULL DEFAULT FALSE, -- DoNotContact__c
  mailbox_status                  VARCHAR(255),                   -- Mailbox_Status__c
  linkedin                        VARCHAR(255),                   -- LinkedIn__c (URL)
  linkedin_company_id             VARCHAR(80),                    -- LID__LinkedIn_Company_Id__c
  linkedin_member_token           VARCHAR(80),                    -- LID__LinkedIn_Member_Token__c
  photo_url                       VARCHAR(255),                   -- PhotoUrl
  website                         VARCHAR(255),
  unsubscribed                    BOOLEAN NOT NULL DEFAULT FALSE, -- Unsubscribed__c
  newsletter_status               VARCHAR(10),                    -- Newsletter_Status__c
  jrsl_unsubscribe_link           VARCHAR(1300),                  -- jrsl_ul_Unsubscribe_Link_Lead__c

  -- ── Address ───────────────────────────────────────────────
  street                          VARCHAR(255),
  city                            VARCHAR(40),
  state                           VARCHAR(80),
  state_code                      VARCHAR(10),                    -- StateCode
  postal_code                     VARCHAR(20),
  country                         VARCHAR(80),
  country_code                    CHAR(2),                        -- CountryCode
  country_picklist                VARCHAR(255),                   -- Country__c (picklist)
  country_code_formula            VARCHAR(1300),                  -- CountryCode__c (formula)
  latitude                        NUMERIC(18,15),
  longitude                       NUMERIC(18,15),
  geocode_accuracy                crm.lead_geocode_accuracy,

  -- ── Lead classification ───────────────────────────────────
  status                          crm.lead_status NOT NULL DEFAULT 'New',
  lead_source                     crm.lead_source,
  lead_category                   crm.lead_category,             -- Lead_Category__c
  rating                          crm.rating,
  industry                        crm.lead_industry,
  department                      crm.lead_department,           -- Department__c
  role_level                      crm.lead_role_level,           -- RoleLevel__c
  lead_role                       VARCHAR(4099),                 -- LeadRole__c (multipicklist → stored as delimited text)
  academic_status                 crm.lead_academic_status,      -- AcademicStatus__c
  language                        VARCHAR(10),                   -- Language__c
  currency_iso_code               crm.lead_currency_iso NOT NULL DEFAULT 'USD',
  profit_center                   crm.lead_profit_center,        -- ProfitCenter__c
  platform                        crm.lead_platform,             -- Platform__c
  subscription_status             crm.lead_subscription_status,  -- SubscriptionStatus__c

  -- ── Financial / company metrics ───────────────────────────
  annual_revenue                  NUMERIC(18,0),
  expected_revenue                NUMERIC(18,2),                 -- Expected_Revenue__c
  number_of_employees             INTEGER,                       -- NumberOfEmployees (int)
  number_of_employees_range       crm.lead_number_of_employees,  -- Number_of_Employees__c (picklist)
  number_of_registered_users      crm.lead_number_registered_users, -- Number_of_registered_users__c
  revenue_range                   crm.lead_revenue_range,        -- Revenue__c
  paid_accounts_in_company        BOOLEAN,                       -- Paid_Accounts_in_Company__c (Yes/No → bool)
  customer_status                 VARCHAR(1300),                 -- CustomerStatus__c

  -- ── Scoring ───────────────────────────────────────────────
  category_score                  NUMERIC(18,0),                 -- CategoryScore__c (PERCENT)
  company_score                   NUMERIC(18,2),                 -- CompanyScore__c (PERCENT)
  person_score                    NUMERIC(18,2),                 -- PersonScore__c (PERCENT)
  lead_info_score                 NUMERIC(18,2),                 -- LeadInfoScore__c (PERCENT)
  lead_score_cdp                  NUMERIC(18,0),                 -- LeadScoreInCDP__c
  lead_score_stars                VARCHAR(1300),                 -- Lead_Score_Stars__c

  -- ── Products ─────────────────────────────────────────────
  product_of_interest             crm.lead_product_of_interest,  -- ProductOfInterest__c
  product_of_interest_multi       VARCHAR(4099),                 -- Product_of_Interest_Multi__c (multipicklist)

  -- ── Lead source / UTM / form ─────────────────────────────
  form_url                        VARCHAR(250),                  -- FormURL__c
  utm_parameter                   VARCHAR(250),                  -- UTMParameter__c
  search_terms                    VARCHAR(255),                  -- SearchTerms__c
  last_campaign_touchpoint        VARCHAR(255),                  -- LastCampaignTouchpoint__c
  lead_locale                     VARCHAR(1300),                 -- Lead_Locale__c
  lead_source_icon                VARCHAR(1300),                 -- LeadSource_Icon__c

  -- ── Status in CDP / MQL ───────────────────────────────────
  lead_status_cdp                 crm.lead_status_cdp,           -- LeadStatusInCDP__c

  -- ── Unqualify ─────────────────────────────────────────────
  unqualify_reason                crm.lead_unqualify_reason,     -- UnqualifyReason__c

  -- ── Conversion ───────────────────────────────────────────
  is_converted                    BOOLEAN NOT NULL DEFAULT FALSE,
  converted_date                  DATE,
  converted_account_id            UUID REFERENCES crm.account(id),
  converted_contact_id            UUID,
  converted_opportunity_id        UUID,
  converted_flow_trigger          BOOLEAN NOT NULL DEFAULT FALSE, -- ConvertedFlowTrigger__c

  -- ── Outreach / sequencing ─────────────────────────────────
  outreach_actively_sequenced     BOOLEAN NOT NULL DEFAULT FALSE, -- Outreach_Actively_being_sequenced__c
  outreach_current_sequence_id    VARCHAR(255),
  outreach_current_sequence_name  VARCHAR(255),
  outreach_current_sequence_status VARCHAR(255),
  outreach_sequence_step_number   NUMERIC(5,0),
  outreach_sequence_step_type     VARCHAR(255),
  outreach_sequence_task_due_date TIMESTAMPTZ,
  outreach_date_added_to_sequence DATE,
  outreach_finished_sequences     TEXT,                           -- 30000 char
  outreach_num_active_sequences   VARCHAR(5),

  -- ── Cadence ───────────────────────────────────────────────
  last_cadence_action             crm.lead_cadence_action,       -- Last_Cadence_Action__c
  last_cadence_action_date        TIMESTAMPTZ,                   -- Last_Cadence_Action_Date__c

  -- ── Webinar ───────────────────────────────────────────────
  attended_webinar                BOOLEAN NOT NULL DEFAULT FALSE, -- Attended_Webinar__c
  interest_in_webinar             BOOLEAN NOT NULL DEFAULT FALSE, -- InterestInWebinar__c
  gotw_channel                    crm.lead_gtw_channel,          -- GoToWebinarChannel__c
  gotw_country                    VARCHAR(100),                  -- GoToWebinarCountry__c
  gotw_industry                   VARCHAR(100),                  -- GoToWebinarIndustry__c
  gotw_email                      VARCHAR(255),                  -- GTWEmail__c
  latest_webinar_date             DATE,                          -- LatestWebinarDate__c
  synced_via_gtw                  BOOLEAN NOT NULL DEFAULT FALSE, -- SyncedViaGTW__c (del)

  -- ── Duration metrics ─────────────────────────────────────
  duration_new_to_qualification   NUMERIC(18,2),                 -- DurationNewToQualification__c
  duration_new_to_screening       NUMERIC(18,0),                 -- DurationNewToScreening__c
  duration_new_to_screening_owner NUMERIC(18,2),                 -- DurationNewtoScreeningOwner__c
  duration_screening_to_qual      NUMERIC(18,0),                 -- DurationScreeningToQualification__c
  duration_screening_own_to_qual  NUMERIC(18,2),                 -- DurationScreeningOwntoQualification__c
  duration_qual_to_discovery      NUMERIC(18,0),                 -- DurationQualificationToDiscovery__c
  duration_qual_to_convert        NUMERIC(18,0),                 -- DurationQualificationToConvert__c
  duration_discovery_to_convert   NUMERIC(18,0),                 -- DurationDiscoveryToConvert__c
  duration_new_to_converted       NUMERIC(18,0),                 -- DurationNewToConverted__c
  db_lead_age                     NUMERIC(18,0),                 -- DB_Lead_Age__c
  lastmodified_hour               NUMERIC(18,0),                 -- LastmodifiedHour__c
  count_industry_changes          NUMERIC(18,0),                 -- CountofIndustryChanges__c
  count_sm_changes                NUMERIC(18,0),                 -- CountofSMChanges__c
  industry_changes                NUMERIC(18,2),                 -- IndustryChanges__c
  sm_changes                      NUMERIC(18,2),                 -- SMChanges__c

  -- ── Timestamps (status progression) ──────────────────────
  timestamp_new                   TIMESTAMPTZ,                   -- TimestampNew__c
  timestamp_mql                   TIMESTAMPTZ,                   -- TimestampMQL__c
  timestamp_screening             TIMESTAMPTZ,                   -- TimestampScreening__c
  timestamp_screening_owner       TIMESTAMPTZ,                   -- TimestampScreeningOwner__c
  timestamp_qualification         TIMESTAMPTZ,                   -- TimestampQualification__c
  timestamp_outreach              TIMESTAMPTZ,                   -- TimestampOutreach__c
  timestamp_unqualified           TIMESTAMPTZ,                   -- Timestamp_Unqualified__c
  timestamp_converted_unqualified TIMESTAMPTZ,                   -- TimestampConvertedUnqualified__c

  -- ── Activity tracking ─────────────────────────────────────
  first_call_date_time            TIMESTAMPTZ,                   -- FirstCallDateTime
  first_email_date_time           TIMESTAMPTZ,                   -- FirstEmailDateTime
  last_activity_date              DATE,                          -- LastActivityDate
  last_meaningful_connect         DATE,                          -- LastMeaningfulConnect__c
  last_transfer_date              DATE,                          -- LastTransferDate
  last_referenced_date            TIMESTAMPTZ,                   -- LastReferencedDate
  last_viewed_date                TIMESTAMPTZ,                   -- LastViewedDate

  -- ── Sales team / assignment ───────────────────────────────
  lead_owner_name                 VARCHAR(1300),                 -- Lead_Owner_Name__c
  owner_sales_team                VARCHAR(1300),                 -- Owner_Sales_Team__c
  owner_profit_center             VARCHAR(1300),                 -- OwnerProfitCenter__c
  owner_role                      VARCHAR(1300),                 -- OwnerRole__c
  owner_meeting_link              VARCHAR(1300),                 -- OwnerMeetingLink__c
  qualified_by                    VARCHAR(1300),                 -- Qualified_by__c
  qualified_by_role               VARCHAR(1300),                 -- Qualified_by_Role__c
  qualification_guideline         VARCHAR(1300),                 -- Qualification_Guideline__c
  sales_representative_id         UUID,                          -- Sales_Representative__c (ref)
  screening_user_id               UUID,                          -- ScreeningUser__c (ref)
  sdr_fls_id                      UUID,                          -- SDRFLS__c (ref)
  next_steps                      VARCHAR(255),                  -- Next_Steps__c

  -- ── Backend / integration ────────────────────────────────
  backend_user_id                 VARCHAR(25),                   -- BackendUserID__c
  backend_user_deleted            BOOLEAN NOT NULL DEFAULT FALSE, -- BackendUserDeleted__c
  username                        VARCHAR(80),                   -- Username__c
  jigsaw                          VARCHAR(20),                   -- Jigsaw
  jigsaw_contact_id               VARCHAR(20),                   -- JigsawContactId
  master_data                     VARCHAR(255),                  -- MasterData__c
  domain                          VARCHAR(1300),                 -- Domain__c
  sub_domain                      VARCHAR(1300),                 -- Sub_Domain__c
  primary_domain                  VARCHAR(1300),                 -- Primary_Domain__c
  search_link_domain              VARCHAR(1300),                 -- SearchLinkDomain__c
  concatinated_name               VARCHAR(1300),                 -- Concatinated_Name__c
  hidden_currency_country_mapping VARCHAR(1300),                 -- HiddenCurrencyCountryMapping__c
  customer_insights_id            VARCHAR(1300),                 -- HiddenEmailForAccountEmail__c
  vertical_responsibility         VARCHAR(1300),                 -- Vertical_Responsibility__c
  lead_18char_id                  VARCHAR(1300),                 -- Lead18CharacterId__c
  lead_locale_formula             VARCHAR(1300),                 -- Lead_Locale__c (formula dup)
  is_priority_record              BOOLEAN NOT NULL DEFAULT FALSE, -- IsPriorityRecord
  is_unread_by_owner              BOOLEAN NOT NULL DEFAULT FALSE, -- IsUnreadByOwner
  is_crm_deleted                  BOOLEAN NOT NULL DEFAULT FALSE, -- IsCRMDeleted__c
  is_vr_bypassed                  BOOLEAN NOT NULL DEFAULT FALSE, -- IsVRBypassed__c
  deletion_request                BOOLEAN NOT NULL DEFAULT FALSE, -- DeletionRequest__c
  dcacc_match_customer_flag       BOOLEAN NOT NULL DEFAULT FALSE, -- DCAccMatchCustomerFlag__c
  predefined_filter_crossobject   BOOLEAN NOT NULL DEFAULT FALSE, -- PredefinedFilterCrossObjectDC__c
  change_to_discovery_automation  BOOLEAN NOT NULL DEFAULT FALSE, -- ChangeToDiscoveryByAutomation__c
  enriched                        BOOLEAN NOT NULL DEFAULT FALSE, -- Enriched__c
  enriched_date                   DATE,                          -- EnrichedDate__c
  clay_last_enrichment            TIMESTAMPTZ,                   -- Clay__Last_Enrichment_By_Clay__c
  validation_bypass_datetime      TIMESTAMPTZ,                   -- ValidationBypassDateTime__c
  created_via_outlook             BOOLEAN NOT NULL DEFAULT FALSE, -- CreatedViaOutlook__c
  screening_view_filter           BOOLEAN NOT NULL DEFAULT FALSE, -- Screening_View_Filter__c
  profit_center_layout_filter     BOOLEAN NOT NULL DEFAULT FALSE, -- Profit_Center_Layout_Filter__c
  db_created_date_without_time    DATE,                          -- DB_Created_Date_without_Time__c
  created_date_formula            DATE,                          -- CreatedDateFormula__c
  description                     TEXT,                          -- Description (32000)
  lead_description                TEXT,                          -- LeadDescription__c (32768)
  company_insights_name           VARCHAR(255),                  -- selectedCompanyInsightsName__c
  company_insights_url            VARCHAR(255),                  -- selectedCompanyInsightsURL__c
  lead_assignment_log             TEXT,                          -- LeadAssignmentLoging__c
  prospect_research               TEXT,                          -- Prospect_Research__c
  dupcheck_index                  TEXT,                          -- dupcheck__dc3Index__c
  dupcheck_disable                BOOLEAN NOT NULL DEFAULT FALSE, -- dupcheck__dc3DisableDuplicateCheck__c
  dupcheck_web2lead               BOOLEAN NOT NULL DEFAULT FALSE, -- dupcheck__dc3Web2Lead__c
  outreach_num_active_seq_str     VARCHAR(5),                    -- Outreach_Number_of_Active_Sequences__c
  last_name_for_duplicatecheck    VARCHAR(1300),                 -- LastNameForDuplicatecheck__c
  case_id                         UUID,                          -- Case__c (ref)

  -- ── Soft delete / audit ───────────────────────────────────
  is_deleted                      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at                      TIMESTAMPTZ,
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── updated_at trigger ────────────────────────────────────────
CREATE TRIGGER trg_lead_updated
  BEFORE UPDATE ON crm.lead
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ── RLS ───────────────────────────────────────────────────────
ALTER TABLE crm.lead ENABLE ROW LEVEL SECURITY;
CREATE POLICY lead_isolation ON crm.lead
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- ── Audit trigger ─────────────────────────────────────────────
CREATE TRIGGER trg_audit_lead
  AFTER INSERT OR UPDATE OR DELETE ON crm.lead
  FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger();

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX idx_lead_tenant          ON crm.lead (tenant_id);
CREATE INDEX idx_lead_owner           ON crm.lead (tenant_id, owner_id);
CREATE INDEX idx_lead_status          ON crm.lead (tenant_id, status);
CREATE INDEX idx_lead_converted       ON crm.lead (tenant_id, is_converted);
CREATE INDEX idx_lead_email           ON crm.lead (tenant_id, email);
CREATE INDEX idx_lead_company         ON crm.lead (tenant_id, company);
CREATE INDEX idx_lead_created         ON crm.lead (tenant_id, created_at DESC);
CREATE INDEX idx_lead_not_deleted     ON crm.lead (tenant_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_lead_open            ON crm.lead (tenant_id, owner_id)
  WHERE is_converted = FALSE AND is_deleted = FALSE;
CREATE INDEX idx_lead_mql             ON crm.lead (tenant_id, timestamp_mql)
  WHERE status = 'MQL' AND is_deleted = FALSE;
CREATE INDEX idx_lead_name_trgm       ON crm.lead USING GIN (name gin_trgm_ops);
CREATE INDEX idx_lead_company_trgm    ON crm.lead USING GIN (company gin_trgm_ops);
CREATE INDEX idx_lead_source          ON crm.lead (tenant_id, lead_source);
CREATE INDEX idx_lead_industry        ON crm.lead (tenant_id, industry);
CREATE INDEX idx_lead_profit_center   ON crm.lead (tenant_id, profit_center);
CREATE INDEX idx_lead_product         ON crm.lead (tenant_id, product_of_interest);
CREATE INDEX idx_lead_screening_user  ON crm.lead (tenant_id, screening_user_id);
CREATE INDEX idx_lead_sdr             ON crm.lead (tenant_id, sdr_fls_id);
