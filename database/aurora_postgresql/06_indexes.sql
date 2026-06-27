-- =============================================================
-- 06_indexes.sql
-- Run as: crm_admin
-- All indexes: every key starts with tenant_id for RLS alignment
-- =============================================================

SET search_path = crm, public;

-- ── tenant ───────────────────────────────────────────────────
CREATE INDEX idx_tenant_slug         ON crm.tenant (slug);
CREATE INDEX idx_tenant_is_active    ON crm.tenant (is_active) WHERE is_active = TRUE;

-- ── app_user ─────────────────────────────────────────────────
CREATE INDEX idx_user_tenant         ON crm.app_user (tenant_id);
CREATE INDEX idx_user_email          ON crm.app_user (tenant_id, email);
CREATE INDEX idx_user_active         ON crm.app_user (tenant_id, is_active) WHERE is_active = TRUE;

-- ── currency ─────────────────────────────────────────────────
CREATE INDEX idx_currency_tenant     ON crm.currency (tenant_id);
CREATE INDEX idx_currency_default    ON crm.currency (tenant_id) WHERE is_default = TRUE;

-- ── account ──────────────────────────────────────────────────
CREATE INDEX idx_account_tenant            ON crm.account (tenant_id);
CREATE INDEX idx_account_owner             ON crm.account (tenant_id, owner_id);
CREATE INDEX idx_account_name_trgm         ON crm.account USING GIN (name gin_trgm_ops);
CREATE INDEX idx_account_type              ON crm.account (tenant_id, type);
CREATE INDEX idx_account_industry          ON crm.account (tenant_id, industry);
CREATE INDEX idx_account_parent            ON crm.account (tenant_id, parent_account_id);
CREATE INDEX idx_account_created           ON crm.account (tenant_id, created_at DESC);
CREATE INDEX idx_account_not_deleted       ON crm.account (tenant_id) WHERE is_deleted = FALSE;

-- ── contact ──────────────────────────────────────────────────
CREATE INDEX idx_contact_tenant            ON crm.contact (tenant_id);
CREATE INDEX idx_contact_account           ON crm.contact (tenant_id, account_id);
CREATE INDEX idx_contact_owner             ON crm.contact (tenant_id, owner_id);
CREATE INDEX idx_contact_email             ON crm.contact (tenant_id, email);
CREATE INDEX idx_contact_name_trgm         ON crm.contact USING GIN (name gin_trgm_ops);
CREATE INDEX idx_contact_created           ON crm.contact (tenant_id, created_at DESC);
CREATE INDEX idx_contact_not_deleted       ON crm.contact (tenant_id) WHERE is_deleted = FALSE;

-- ── lead ─────────────────────────────────────────────────────
CREATE INDEX idx_lead_tenant               ON crm.lead (tenant_id);
CREATE INDEX idx_lead_owner                ON crm.lead (tenant_id, owner_id);
CREATE INDEX idx_lead_status               ON crm.lead (tenant_id, status);
CREATE INDEX idx_lead_converted            ON crm.lead (tenant_id, is_converted);
CREATE INDEX idx_lead_email                ON crm.lead (tenant_id, email);
CREATE INDEX idx_lead_name_trgm            ON crm.lead USING GIN (name gin_trgm_ops);
CREATE INDEX idx_lead_company_trgm         ON crm.lead USING GIN (company gin_trgm_ops);
CREATE INDEX idx_lead_created              ON crm.lead (tenant_id, created_at DESC);
CREATE INDEX idx_lead_not_deleted          ON crm.lead (tenant_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_lead_open                 ON crm.lead (tenant_id, owner_id)
  WHERE is_converted = FALSE AND is_deleted = FALSE;

-- ── opportunity ──────────────────────────────────────────────
CREATE INDEX idx_opp_tenant                ON crm.opportunity (tenant_id);
CREATE INDEX idx_opp_account               ON crm.opportunity (tenant_id, account_id);
CREATE INDEX idx_opp_owner                 ON crm.opportunity (tenant_id, owner_id);
CREATE INDEX idx_opp_stage                 ON crm.opportunity (tenant_id, stage_name);
CREATE INDEX idx_opp_close_date            ON crm.opportunity (tenant_id, close_date);
CREATE INDEX idx_opp_forecast              ON crm.opportunity (tenant_id, forecast_category);
CREATE INDEX idx_opp_amount                ON crm.opportunity (tenant_id, amount DESC);
CREATE INDEX idx_opp_open_pipeline         ON crm.opportunity (tenant_id, close_date, amount)
  WHERE is_closed = FALSE AND is_deleted = FALSE;
CREATE INDEX idx_opp_won                   ON crm.opportunity (tenant_id, close_date)
  WHERE is_won = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_opp_created               ON crm.opportunity (tenant_id, created_at DESC);
CREATE INDEX idx_opp_name_trgm             ON crm.opportunity USING GIN (name gin_trgm_ops);

-- ── opportunity_contact_role ─────────────────────────────────
CREATE INDEX idx_ocr_opportunity           ON crm.opportunity_contact_role (tenant_id, opportunity_id);
CREATE INDEX idx_ocr_contact               ON crm.opportunity_contact_role (tenant_id, contact_id);

-- ── product ──────────────────────────────────────────────────
CREATE INDEX idx_product_tenant            ON crm.product (tenant_id);
CREATE INDEX idx_product_family            ON crm.product (tenant_id, family);
CREATE INDEX idx_product_active            ON crm.product (tenant_id) WHERE is_active = TRUE AND is_deleted = FALSE;
CREATE INDEX idx_product_name_trgm         ON crm.product USING GIN (name gin_trgm_ops);
CREATE INDEX idx_product_code              ON crm.product (tenant_id, product_code);

-- ── pricebook ────────────────────────────────────────────────
CREATE INDEX idx_pricebook_tenant          ON crm.pricebook (tenant_id);
CREATE INDEX idx_pricebook_active          ON crm.pricebook (tenant_id) WHERE is_active = TRUE AND is_deleted = FALSE;

-- ── pricebook_entry ──────────────────────────────────────────
CREATE INDEX idx_pbe_tenant                ON crm.pricebook_entry (tenant_id);
CREATE INDEX idx_pbe_pricebook             ON crm.pricebook_entry (tenant_id, pricebook_id);
CREATE INDEX idx_pbe_product               ON crm.pricebook_entry (tenant_id, product_id);
CREATE INDEX idx_pbe_active                ON crm.pricebook_entry (tenant_id, pricebook_id)
  WHERE is_active = TRUE AND is_deleted = FALSE;

-- ── quote ────────────────────────────────────────────────────
CREATE INDEX idx_quote_tenant              ON crm.quote (tenant_id);
CREATE INDEX idx_quote_opportunity         ON crm.quote (tenant_id, opportunity_id);
CREATE INDEX idx_quote_owner               ON crm.quote (tenant_id, owner_id);
CREATE INDEX idx_quote_status              ON crm.quote (tenant_id, status);
CREATE INDEX idx_quote_expiry              ON crm.quote (tenant_id, expiration_date);
CREATE INDEX idx_quote_created             ON crm.quote (tenant_id, created_at DESC);

-- ── quote_line_item ──────────────────────────────────────────
CREATE INDEX idx_qli_quote                 ON crm.quote_line_item (tenant_id, quote_id);
CREATE INDEX idx_qli_product               ON crm.quote_line_item (tenant_id, product_id);

-- ── contract ─────────────────────────────────────────────────
CREATE INDEX idx_contract_tenant           ON crm.contract (tenant_id);
CREATE INDEX idx_contract_account          ON crm.contract (tenant_id, account_id);
CREATE INDEX idx_contract_owner            ON crm.contract (tenant_id, owner_id);
CREATE INDEX idx_contract_status           ON crm.contract (tenant_id, status);
CREATE INDEX idx_contract_end_date         ON crm.contract (tenant_id, end_date);
CREATE INDEX idx_contract_active           ON crm.contract (tenant_id, end_date)
  WHERE status = 'Activated' AND is_deleted = FALSE;
CREATE INDEX idx_contract_renewal          ON crm.contract (tenant_id, end_date)
  WHERE auto_renew = TRUE AND status = 'Activated' AND is_deleted = FALSE;
CREATE INDEX idx_contract_created          ON crm.contract (tenant_id, created_at DESC);

-- ── contract_line_item ───────────────────────────────────────
CREATE INDEX idx_cli_contract              ON crm.contract_line_item (tenant_id, contract_id);
CREATE INDEX idx_cli_product               ON crm.contract_line_item (tenant_id, product_id);
CREATE INDEX idx_cli_quote_line            ON crm.contract_line_item (tenant_id, quote_line_item_id);

-- ── contract_line_item_seat ──────────────────────────────────
CREATE INDEX idx_clis_cli                  ON crm.contract_line_item_seat (tenant_id, contract_line_item_id);
CREATE INDEX idx_clis_contract             ON crm.contract_line_item_seat (tenant_id, contract_id);
CREATE INDEX idx_clis_contact              ON crm.contract_line_item_seat (tenant_id, assigned_contact_id);
CREATE INDEX idx_clis_user                 ON crm.contract_line_item_seat (tenant_id, assigned_user_id);
CREATE INDEX idx_clis_active               ON crm.contract_line_item_seat (tenant_id, contract_id)
  WHERE is_active = TRUE AND is_deleted = FALSE;

-- ── clearing_house ───────────────────────────────────────────
CREATE INDEX idx_ch_tenant                 ON crm.clearing_house (tenant_id);
CREATE INDEX idx_ch_contract               ON crm.clearing_house (tenant_id, contract_id);
CREATE INDEX idx_ch_cli                    ON crm.clearing_house (tenant_id, contract_line_item_id);
CREATE INDEX idx_ch_event_type             ON crm.clearing_house (tenant_id, event_type);
CREATE INDEX idx_ch_status                 ON crm.clearing_house (tenant_id, status);
CREATE INDEX idx_ch_event_date             ON crm.clearing_house (tenant_id, event_date);
CREATE INDEX idx_ch_recognition            ON crm.clearing_house (tenant_id, recognition_start_date, recognition_end_date)
  WHERE is_deleted = FALSE;
CREATE INDEX idx_ch_pending                ON crm.clearing_house (tenant_id, due_date)
  WHERE status = 'Pending' AND is_deleted = FALSE;

-- ── activity & task ──────────────────────────────────────────
CREATE INDEX idx_activity_tenant           ON crm.activity (tenant_id);
CREATE INDEX idx_activity_who              ON crm.activity (tenant_id, who_type, who_id);
CREATE INDEX idx_activity_what             ON crm.activity (tenant_id, what_type, what_id);
CREATE INDEX idx_activity_owner            ON crm.activity (tenant_id, owner_id);
CREATE INDEX idx_task_tenant               ON crm.task (tenant_id);
CREATE INDEX idx_task_owner                ON crm.task (tenant_id, owner_id);
CREATE INDEX idx_task_status               ON crm.task (tenant_id, status) WHERE is_closed = FALSE;
CREATE INDEX idx_task_due                  ON crm.task (tenant_id, activity_date) WHERE is_closed = FALSE;
