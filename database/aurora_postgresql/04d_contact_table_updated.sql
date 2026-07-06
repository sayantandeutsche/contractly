-- =============================================================
-- 04d_contact_table_updated.sql
-- Drop and recreate crm.contact based on actual Salesforce
-- Contact field definitions from apex log
-- Run as: crm_admin
-- Prerequisite: crm.account must exist (04c_account_table_updated.sql)
-- =============================================================

SET search_path = crm, public;

-- ── Drop dependent objects first ─────────────────────────────
DROP TABLE IF EXISTS crm.opportunity_contact_role CASCADE;
DROP TABLE IF EXISTS crm.contact                  CASCADE;

-- ── Drop old contact-related enums ───────────────────────────
DROP TYPE IF EXISTS crm.contact_role CASCADE;

-- ══════════════════════════════════════════════════════════════
-- ENUMS — from actual Salesforce picklist values
-- ══════════════════════════════════════════════════════════════

CREATE TYPE crm.contact_salutation AS ENUM (
    'MR_', 'MRS_', 'MX_', 'Herr', 'Frau'
);

CREATE TYPE crm.contact_academic_title AS ENUM (
    'Dr.', 'Prof.', 'Prof. Dr', 'Mag.'
);

CREATE TYPE crm.contact_academic_status AS ENUM (
    'STUDENT', 'GRADUATE'
);

CREATE TYPE crm.contact_account_type AS ENUM (
    'EMPLOYEE_ACCOUNT', 'GROUP_ACCOUNT', 'SINGLE_ACCOUNT'
);

CREATE TYPE crm.contact_currency_iso AS ENUM (
    'AUD', 'GBP', 'EUR', 'INR', 'JPY', 'SGD', 'USD'
);

CREATE TYPE crm.contact_department AS ENUM (
    'Executive & Leadership', 'Strategy & Business Development',
    'Marketing & Growth', 'Sales & Revenue Operations',
    'Business Intelligence & Analytics', 'Research & Insights',
    'Product Management', 'Finance & Accounting', 'Operations',
    'Technology & Engineering', 'Communications & PR',
    'Education & Training', 'HR', 'Legal & Compliance', 'Other'
);

CREATE TYPE crm.contact_department_group AS ENUM (
    'chiefExecutive', 'sales', 'finance', 'tech', 'support',
    'legal', 'humanResources', 'customerSuccess', 'marketing', 'other'
);

CREATE TYPE crm.contact_gender_identity AS ENUM (
    'Male', 'Female', 'Nonbinary', 'Not Listed'
);

CREATE TYPE crm.contact_pronouns AS ENUM (
    'He/Him', 'She/Her', 'They/Them', 'He/They', 'She/They', 'Not Listed'
);

CREATE TYPE crm.contact_lead_source AS ENUM (
    'Academia Availability Request', 'Andzup', 'Apollo', 'Chrunchbase',
    'Clay', 'Client Service', 'Cold Call', 'Cold Mailing', 'Customer Visit',
    'Inbound', 'Linkedin', 'LinkedIn Lead Gen', 'Mailchimp', 'Other',
    'Outbound', 'Partnership', 'Pendo', 'Reference', 'Salesviewer',
    'Seamless.AI', 'Webform', 'Webinar', 'Whitepaper', 'Winmo',
    'Yesware', 'Zoominfo'
);

CREATE TYPE crm.contact_role AS ENUM (
    'User Buyer', 'Billing Contact', 'Economic Buyer', 'Sabateur',
    'Coach', 'Technical Buyer', 'Other'
);

CREATE TYPE crm.contact_role_level AS ENUM (
    'Student', 'Team Member', 'Manager', 'Director / VP',
    'C-Level / Owner', 'External / Consultant'
);

CREATE TYPE crm.contact_title_type AS ENUM (
    'ceo', 'executive', 'vp', 'directorOrManager', 'individualContributor'
);

CREATE TYPE crm.contact_platform AS ENUM (
    'ENGLISH', 'GERMAN', 'FRENCH', 'SPANISH', 'EcommerceDB'
);

CREATE TYPE crm.contact_subscription_status AS ENUM (
    'former subscriber', 'free subscriber', 'non-subscriber',
    'subscriber', 'write-off'
);

CREATE TYPE crm.contact_user_status AS ENUM (
    'PaidUser', 'User'
);

CREATE TYPE crm.contact_user_integration_status AS ENUM (
    'Completed', 'EmailMismatch', 'EmailIsNull',
    'UserIdMissing', 'DuplicateContact'
);

CREATE TYPE crm.contact_not_at_company AS ENUM (
    'Not at Company', 'Ignore'
);

CREATE TYPE crm.contact_contact_source AS ENUM (
    'Auto Create', 'Email Message', 'Meeting Digest', 'Seller Home'
);

CREATE TYPE crm.contact_geocode_accuracy AS ENUM (
    'Address', 'NearAddress', 'Block', 'Street', 'ExtendedZip',
    'Zip', 'Neighborhood', 'City', 'County', 'State', 'Unknown'
);

CREATE TYPE crm.contact_cadence_action AS ENUM (
    'Removed – Commercial Opt-Out', 'Removed – Unqualified'
);

CREATE TYPE crm.contact_product_of_interest AS ENUM (
    'None', 'ASK_STATISTA', 'BASIC_ACCOUNT', 'BASIC_ACCOUNT_PLUS',
    'CAMPUS_LICENSE_INT', 'COMPANY_DATABASE', 'CORPORATE_ACCOUNT',
    'DOSSIER', 'ECOMMERCE_DB', 'ENTERPRISE_ACCOUNT',
    'GLOBAL_CONSUMER_SURVEY', 'PPT_CUSTOMIZATION', 'PROJECT_ACCOUNT',
    'SINGLE_ACCOUNT', 'SINGLE_ACCOUNT_TEST', 'WEBINAR', 'LICENSE_PRICING',
    'LOGIN_ACCESS', 'OTHER', 'PERSONAL_ACCOUNT', 'PROFESSIONAL_ACCOUNT',
    'BUSINESS_SUITE', 'COMPANY_INSIGHTS', 'CONSUMER_INSIGHTS',
    'ECOMMERCE_INSIGHTS', 'STARTER_ACCOUNT', 'STARTER_ACCOUNT_TEST', 'API'
);

CREATE TYPE crm.contact_gtw_channel AS ENUM (
    'Email', 'Instagram', 'LinkedIn', 'Facebook',
    'Recommendation', 'Statista Website', 'Other'
);

-- ══════════════════════════════════════════════════════════════
-- CONTACT TABLE
-- ══════════════════════════════════════════════════════════════
CREATE TABLE crm.contact (

  -- ── Core / system ─────────────────────────────────────────
  id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                       UUID NOT NULL REFERENCES crm.tenant(id),
  owner_id                        UUID REFERENCES crm.app_user(id),
  created_by_id                   UUID REFERENCES crm.app_user(id),
  last_modified_by_id             UUID REFERENCES crm.app_user(id),
  account_id                      UUID REFERENCES crm.account(id),
  reports_to_id                   UUID,                          -- self-ref, FK added below
  master_record_id                UUID,                          -- MasterRecordId

  -- ── Identity ──────────────────────────────────────────────
  salutation                      crm.contact_salutation,        -- Salutation
  first_name                      VARCHAR(40),                   -- FirstName
  last_name                       VARCHAR(80) NOT NULL,          -- LastName
  name                            VARCHAR(121) GENERATED ALWAYS AS (
                                    COALESCE(first_name || ' ', '') || last_name
                                  ) STORED,
  title                           VARCHAR(128),                  -- Title (Job Title)
  title_type                      crm.contact_title_type,        -- TitleType (Seniority Level)
  academic_title                  crm.contact_academic_title,    -- Academic_Title__c
  academic_status                 crm.contact_academic_status,   -- AcademicStatus__c
  pronouns                        crm.contact_pronouns,          -- Pronouns
  gender_identity                 crm.contact_gender_identity,   -- GenderIdentity
  gender                          VARCHAR(1300),                  -- Gender__c (free text)
  birthdate                       DATE,                          -- Birthdate
  photo_url                       VARCHAR(255),                  -- PhotoUrl
  contact_18char_id               VARCHAR(1300),                 -- Contact18CharacterId__c

  -- ── Department / role ─────────────────────────────────────
  department                      VARCHAR(80),                   -- Department (standard SF)
  department_picklist             crm.contact_department,        -- Department__c (picklist)
  department_group                crm.contact_department_group,  -- DepartmentGroup
  hidden_field_department         VARCHAR(80),                   -- HiddenFieldDepartment__c
  role                            VARCHAR(4099),                 -- Role__c (multipicklist)
  role_level                      crm.contact_role_level,        -- RoleLevel__c
  buyer_attributes                VARCHAR(4099),                 -- BuyerAttributes (multipicklist)
  assistant_name                  VARCHAR(40),                   -- AssistantName
  assistant_phone                 VARCHAR(40),                   -- AssistantPhone

  -- ── Contact info ──────────────────────────────────────────
  email                           VARCHAR(80),                   -- Email
  email_2                         VARCHAR(80),                   -- Email_2__c
  linkedin_work_email             VARCHAR(80),                   -- LinkedInWorkEmail__c
  email_bounced_date              TIMESTAMPTZ,                   -- EmailBouncedDate
  email_bounced_reason            VARCHAR(255),                  -- EmailBouncedReason
  is_email_bounced                BOOLEAN NOT NULL DEFAULT FALSE,-- IsEmailBounced
  has_opted_out_of_email          BOOLEAN NOT NULL DEFAULT FALSE,-- HasOptedOutOfEmail
  has_opted_out_of_fax            BOOLEAN NOT NULL DEFAULT FALSE,-- HasOptedOutOfFax
  email_activation                BOOLEAN NOT NULL DEFAULT FALSE,-- EmailActivation__c
  unsubscribed                    BOOLEAN NOT NULL DEFAULT FALSE,-- Unsubscribed__c
  newsletter_status               VARCHAR(10),                   -- NewsletterStatus__c
  jrsl_unsubscribe_link           VARCHAR(1300),                 -- jrsl_ul_Unsubscribe_Link_Contact__c
  phone                           VARCHAR(40),                   -- Phone (Business Phone)
  phone_2                         VARCHAR(40),                   -- Phone_2__c
  mobile_phone                    VARCHAR(40),                   -- MobilePhone
  home_phone                      VARCHAR(40),                   -- HomePhone
  other_phone                     VARCHAR(40),                   -- OtherPhone
  assistant_phone_std             VARCHAR(40),                   -- AssistantPhone (dup, kept for clarity)
  fax                             VARCHAR(40),                   -- Fax (Business Fax)
  do_not_call                     BOOLEAN NOT NULL DEFAULT FALSE,-- DoNotCall
  do_not_contact                  BOOLEAN NOT NULL DEFAULT FALSE,-- DoNotContact__c
  linkedin                        VARCHAR(255),                  -- LinkedIn__c (URL)
  linkedin_company_id             VARCHAR(80),                   -- LID__LinkedIn_Company_Id__c
  linkedin_member_token           VARCHAR(80),                   -- LID__LinkedIn_Member_Token__c
  not_at_company_flag             crm.contact_not_at_company,    -- LID__No_longer_at_Company__c

  -- ── Mailing address (Contact Address) ────────────────────
  mailing_street                  VARCHAR(255),                  -- MailingStreet
  mailing_city                    VARCHAR(40),                   -- MailingCity
  mailing_state                   VARCHAR(80),                   -- MailingState
  mailing_state_code              VARCHAR(10),                   -- MailingStateCode
  mailing_postal_code             VARCHAR(20),                   -- MailingPostalCode
  mailing_country                 VARCHAR(80),                   -- MailingCountry
  mailing_country_code            CHAR(2),                       -- MailingCountryCode
  mailing_latitude                NUMERIC(18,15),                -- MailingLatitude
  mailing_longitude               NUMERIC(18,15),                -- MailingLongitude
  mailing_geocode_accuracy        crm.contact_geocode_accuracy,  -- MailingGeocodeAccuracy
  contact_street                  VARCHAR(120),                  -- ContactStreet__c
  contact_house_number            VARCHAR(20),                   -- ContactHouseNumber__c
  deviating_from_account_address  BOOLEAN NOT NULL DEFAULT FALSE,-- DeviatingFromAccountAddress__c

  -- ── Other address ─────────────────────────────────────────
  other_street                    VARCHAR(255),                  -- OtherStreet
  other_city                      VARCHAR(40),                   -- OtherCity
  other_state                     VARCHAR(80),                   -- OtherState
  other_state_code                VARCHAR(10),                   -- OtherStateCode
  other_postal_code               VARCHAR(20),                   -- OtherPostalCode
  other_country                   VARCHAR(80),                   -- OtherCountry
  other_country_code              CHAR(2),                       -- OtherCountryCode
  other_latitude                  NUMERIC(18,15),                -- OtherLatitude
  other_longitude                 NUMERIC(18,15),                -- OtherLongitude
  other_geocode_accuracy          crm.contact_geocode_accuracy,  -- OtherGeocodeAccuracy

  -- ── Classification ────────────────────────────────────────
  lead_source                     crm.contact_lead_source,       -- LeadSource
  contact_source                  crm.contact_contact_source,    -- ContactSource (Creation Source)
  account_type                    crm.contact_account_type,      -- AccountType__c
  platform                        crm.contact_platform,          -- Platform__c
  product_of_interest             crm.contact_product_of_interest, -- ProductOfInterest__c
  product_of_interest_multi       VARCHAR(4099),                 -- Product_of_Interest_Multi__c (multipicklist)
  subscription_status             crm.contact_subscription_status, -- SubscriptionStatus__c
  contact_status                  VARCHAR(10),                   -- ContactStatus__c (values: 1,2,3,4,5)
  currency_iso_code               crm.contact_currency_iso NOT NULL DEFAULT 'USD',

  -- ── License / access ──────────────────────────────────────
  license_id                      UUID,                          -- License__c (ref)
  license_is_active               BOOLEAN NOT NULL DEFAULT FALSE,-- LicenseIsActive__c
  license_type                    VARCHAR(1300),                 -- LicenseType__c
  user_status                     crm.contact_user_status,       -- UserStatus__c
  user_integration_status         crm.contact_user_integration_status, -- UserIntegrationStatus__c
  username                        VARCHAR(80),                   -- Username__c
  self_service_enabled            BOOLEAN NOT NULL DEFAULT FALSE,-- Self_Service_enabled__c
  statista_circle                 BOOLEAN NOT NULL DEFAULT FALSE,-- Statista_Circle__c
  backend_user_id                 VARCHAR(25),                   -- BackendUserID__c
  backend_user_deleted            BOOLEAN NOT NULL DEFAULT FALSE,-- BackendUserDeleted__c
  backend_master_user_id          VARCHAR(12),                   -- BackendMasterUserID__c
  backend_phone_id                VARCHAR(12),                   -- BackendPhoneID__c
  backend_user_address_id         VARCHAR(12),                   -- BackendUserAddressID__c
  backend_is_master_slave_active  BOOLEAN NOT NULL DEFAULT FALSE,-- BackendisMasterSlaveConnectionActive__c
  kl_contact_id                   VARCHAR(255),                  -- KLContactId__c
  kl_user_id                      VARCHAR(255),                  -- KLUserId__c
  migration_id                    VARCHAR(100),                  -- MigrationId__c
  jigsaw                          VARCHAR(20),                   -- Jigsaw
  jigsaw_contact_id               VARCHAR(20),                   -- JigsawContactId

  -- ── Engagement / usage metrics ───────────────────────────
  active_days_last_90             NUMERIC(5,0),                  -- ActiveDaysLast90Days__c
  content_views_last_60           NUMERIC(5,0),                  -- ContentViewsLast60Days__c
  content_views_last_90           NUMERIC(7,0),                  -- ContentViewsLast90Days__c
  days_with_content_views_last_60 NUMERIC(5,0),                  -- DaysWithContentViewsLast60Days__c
  downloads_last_90               NUMERIC(7,0),                  -- DownloadsLast90Days__c
  research_ai_queries_last_90     NUMERIC(7,0),                  -- ResearchAIQueriesLast90Days__c
  outreach_num_active_tasks       NUMERIC(18,0),                 -- Outreach_Number_of_Active_Tasks__c
  had_content_view_last_60        BOOLEAN NOT NULL DEFAULT FALSE,-- HadContentViewInLast60Days__c
  was_active_last_90              BOOLEAN NOT NULL DEFAULT FALSE,-- WasActiveLast90Days__c
  last_active_date                DATE,                          -- LastActiveDate__c
  last_content_view               DATE,                          -- LastContentView__c

  -- ── Contract formula fields (read from account contract) ─
  contract_id                     UUID,                          -- Contract__c (ref)
  contract_auto_renewal           BOOLEAN,                       -- ContractAutoRenewalFR__c
  contract_start_date             DATE,                          -- ContractStartDateFR__c
  contract_end_date               DATE,                          -- ContractEndDateFR__c
  contract_cancellation_date      DATE,                          -- ContractCancellationDateFR__c
  contract_notice_days            NUMERIC(18,2),                 -- ContractNoticeDaysFR__c
  contract_notice_start           NUMERIC(18,0),                 -- ContractNoticeStartFR__c
  contract_payment_status         VARCHAR(1300),                 -- ContractPaymentStatusFR__c
  contract_po                     VARCHAR(1300),                 -- ContractPOFR__c
  contract_status                 VARCHAR(1300),                 -- ContractStatusFR__c
  follow_up_renewal_percent       NUMERIC(18,2),                 -- FollowUpRenewalPerFR__c
  follow_up_renewal_price         NUMERIC(18,2),                 -- FollowUpRenewalPriceFR__c

  -- ── Account formula fields ────────────────────────────────
  account_name_formula            VARCHAR(1300),                 -- AccountNameFormula__c
  account_owner_formula           VARCHAR(1300),                 -- AccountOwnerFormula__c
  account_billing_email_fr        VARCHAR(1300),                 -- AccountBillingEmailFR__c
  account_billing_street_fr       VARCHAR(1300),                 -- AccountBillingStreetFR__c
  account_city_fr                 VARCHAR(1300),                 -- AccountCityFR__c
  account_cl_address_fr           VARCHAR(1300),                 -- AccountCLAddressFR__c
  account_cl_house_fr             VARCHAR(1300),                 -- AccountCLHouseFR__c
  account_country_fr              VARCHAR(1300),                 -- AccountCountryFR__c
  account_csm_fr                  VARCHAR(1300),                 -- AccountCSM_FR__c
  account_postal_code_fr          VARCHAR(1300),                 -- AccountPostalCodeFR__c
  account_vat_fr                  VARCHAR(1300),                 -- AccountVATFormula
  country_account                 VARCHAR(1300),                 -- CountryAccount__c
  contact_profit_center           VARCHAR(12),                   -- ContactProfitCenter__c
  profit_center_account           VARCHAR(1300),                 -- ProfitCenterAccount__c
  segment                         VARCHAR(1300),                 -- Segment__c (Account Segment, formula)
  owner_profile                   VARCHAR(1300),                 -- OwnerProfile__c

  -- ── Lead conversion ───────────────────────────────────────
  converted_from_lead             BOOLEAN NOT NULL DEFAULT FALSE,-- Converted_from_Lead__c
  converted_lead_id               VARCHAR(1300),                 -- ConvertedLeadID__c

  -- ── Outreach / sequencing ─────────────────────────────────
  outreach_actively_sequenced     BOOLEAN NOT NULL DEFAULT FALSE,-- Outreach_Actively_Being_Sequenced__c
  outreach_current_sequence_id    VARCHAR(255),                  -- Outreach_Current_Sequence_ID__c
  outreach_current_sequence_name  VARCHAR(255),                  -- Outreach_Current_Sequence_Name__c
  outreach_current_sequence_status VARCHAR(255),                 -- Outreach_Current_Sequence_Status__c
  outreach_sequence_step_number   NUMERIC(5,0),                  -- Outreach_Current_Sequence_Step_Number__c
  outreach_sequence_step_type     VARCHAR(255),                  -- Outreach_Current_Sequence_Step_Type__c
  outreach_sequence_task_due_date TIMESTAMPTZ,                   -- Outreach_Current_Sequence_Task_Due_Date__c
  outreach_date_added_to_sequence DATE,                          -- Outreach_Date_Added_to_Sequence__c
  outreach_finished_sequences     TEXT,                          -- Outreach_Finished_Sequences__c (30000)
  outreach_num_active_sequences   VARCHAR(5),                    -- Outreach_Number_of_Active_Sequences__c

  -- ── Cadence ───────────────────────────────────────────────
  last_cadence_action             crm.contact_cadence_action,    -- Last_Cadence_Action__c
  last_cadence_action_date        TIMESTAMPTZ,                   -- Last_Cadence_Action_Date__c

  -- ── Webinar ───────────────────────────────────────────────
  interest_in_webinar             BOOLEAN NOT NULL DEFAULT FALSE,-- InterestInWebinar__c
  gotw_channel                    crm.contact_gtw_channel,       -- GoToWebinarChannel__c (del)
  gotw_country                    VARCHAR(100),                  -- GoToWebinarCountry__c (del)
  gotw_industry                   VARCHAR(100),                  -- GoToWebinarIndustry__c (del)
  gotw_email                      VARCHAR(255),                  -- GTWEmail__c (del)
  synced_via_gtw                  BOOLEAN NOT NULL DEFAULT FALSE,-- SyncedViaGTW__c

  -- ── Activity / date tracking ──────────────────────────────
  first_call_date_time            TIMESTAMPTZ,                   -- FirstCallDateTime
  first_email_date_time           TIMESTAMPTZ,                   -- FirstEmailDateTime
  last_activity_date              DATE,                          -- LastActivityDate
  last_meaningful_connect         DATE,                          -- LastMeaningfulConnect__c
  last_stay_in_touch_request      TIMESTAMPTZ,                   -- LastCURequestDate
  last_stay_in_touch_save         TIMESTAMPTZ,                   -- LastCUUpdateDate
  last_referenced_date            TIMESTAMPTZ,                   -- LastReferencedDate
  last_viewed_date                TIMESTAMPTZ,                   -- LastViewedDate
  user_synchronization_date       TIMESTAMPTZ,                   -- UserSynchronizationDate__c
  clay_last_enrichment            TIMESTAMPTZ,                   -- Clay__Last_Enrichment_By_Clay__c

  -- ── Source / UTM ──────────────────────────────────────────
  form_url                        VARCHAR(250),                  -- FormURL__c
  utm_parameter                   VARCHAR(250),                  -- UTMParameter__c
  salesviewer_country             VARCHAR(100),                  -- SalesviewerCountry__c
  qualified_by                    VARCHAR(255),                  -- Qualified_by__c
  qualified_by_role               VARCHAR(255),                  -- Qualified_by_Role__c

  -- ── Misc flags / integrations ────────────────────────────
  is_hidden_from_end_users        BOOLEAN NOT NULL DEFAULT FALSE,-- IsHiddenFromEndUsers__c
  is_inactive                     BOOLEAN NOT NULL DEFAULT FALSE,-- IsInactive__c
  is_priority_record              BOOLEAN NOT NULL DEFAULT FALSE,-- IsPriorityRecord
  is_web2lead                     BOOLEAN NOT NULL DEFAULT FALSE,-- is_Web2Lead__c
  created_via_outlook             BOOLEAN NOT NULL DEFAULT FALSE,-- CreatedViaOutlook__c
  dupcheck_disable                BOOLEAN NOT NULL DEFAULT FALSE,-- dupcheck__dc3DisableDuplicateCheck__c
  dupcheck_index                  TEXT,                          -- dupcheck__dc3Index__c (32768)
  name_for_duplicatecheck         VARCHAR(1300),                 -- (deduced from pattern)
  language                        VARCHAR(10),                   -- Language__c
  jigsaw_contact_id_str           VARCHAR(20),                   -- JigsawContactId
  description                     TEXT,                          -- Description (32000)
  contact_description             TEXT,                          -- ContactDescription__c (32768)

  -- ── Soft delete / audit ───────────────────────────────────
  is_deleted                      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at                      TIMESTAMPTZ,
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Self-referential FK (reports to) ─────────────────────────
ALTER TABLE crm.contact
  ADD CONSTRAINT fk_contact_reports_to
  FOREIGN KEY (reports_to_id) REFERENCES crm.contact(id);

-- ── updated_at trigger ────────────────────────────────────────
CREATE TRIGGER trg_contact_updated
  BEFORE UPDATE ON crm.contact
  FOR EACH ROW EXECUTE FUNCTION crm.set_updated_at();

-- ── RLS ───────────────────────────────────────────────────────
ALTER TABLE crm.contact ENABLE ROW LEVEL SECURITY;
CREATE POLICY contact_isolation ON crm.contact
  AS PERMISSIVE FOR ALL TO crm_app
  USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::uuid);

-- ── Audit trigger ─────────────────────────────────────────────
CREATE TRIGGER trg_audit_contact
  AFTER INSERT OR UPDATE OR DELETE ON crm.contact
  FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger();

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX idx_contact_tenant           ON crm.contact (tenant_id);
CREATE INDEX idx_contact_account          ON crm.contact (tenant_id, account_id);
CREATE INDEX idx_contact_owner            ON crm.contact (tenant_id, owner_id);
CREATE INDEX idx_contact_email            ON crm.contact (tenant_id, email);
CREATE INDEX idx_contact_name_trgm        ON crm.contact USING GIN (name gin_trgm_ops);
CREATE INDEX idx_contact_reports_to       ON crm.contact (tenant_id, reports_to_id);
CREATE INDEX idx_contact_created          ON crm.contact (tenant_id, created_at DESC);
CREATE INDEX idx_contact_not_deleted      ON crm.contact (tenant_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_contact_lead_source      ON crm.contact (tenant_id, lead_source);
CREATE INDEX idx_contact_subscription     ON crm.contact (tenant_id, subscription_status);
CREATE INDEX idx_contact_platform         ON crm.contact (tenant_id, platform);
CREATE INDEX idx_contact_user_status      ON crm.contact (tenant_id, user_status);
CREATE INDEX idx_contact_license_active   ON crm.contact (tenant_id)
  WHERE license_is_active = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_contact_active_90        ON crm.contact (tenant_id)
  WHERE was_active_last_90 = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_contact_mailing_country  ON crm.contact (tenant_id, mailing_country);
CREATE INDEX idx_contact_outreach_seq     ON crm.contact (tenant_id, outreach_actively_sequenced)
  WHERE outreach_actively_sequenced = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_contact_department       ON crm.contact (tenant_id, department_picklist);
CREATE INDEX idx_contact_role_level       ON crm.contact (tenant_id, role_level);
