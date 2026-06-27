-- =============================================================
-- 08_audit_triggers.sql
-- Run as: crm_admin
-- Append-only audit log: every INSERT/UPDATE/DELETE on core tables
-- is recorded. The audit table itself has no RLS — only crm_admin
-- can query it directly. App code never writes to it directly.
-- =============================================================

SET search_path = crm, public;

-- ── Audit log table ──────────────────────────────────────────
CREATE TABLE crm.audit_log (
  id              BIGSERIAL     PRIMARY KEY,
  tenant_id       UUID          NOT NULL,
  table_name      TEXT          NOT NULL,
  record_id       UUID          NOT NULL,
  operation       CHAR(1)       NOT NULL CHECK (operation IN ('I','U','D')),
  changed_by_id   UUID,                        -- app_user performing the change
  changed_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
  old_data        JSONB,
  new_data        JSONB,
  ip_address      INET,
  session_id      TEXT
);

-- Partition-ready: index by tenant + table + time
CREATE INDEX idx_audit_tenant_table_time
  ON crm.audit_log (tenant_id, table_name, changed_at DESC);
CREATE INDEX idx_audit_record
  ON crm.audit_log (tenant_id, record_id, changed_at DESC);
CREATE INDEX idx_audit_operation
  ON crm.audit_log (tenant_id, operation, changed_at DESC);

-- ── Generic audit trigger function ───────────────────────────
CREATE OR REPLACE FUNCTION crm.fn_audit_trigger()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_tenant_id UUID;
  v_record_id UUID;
  v_op        CHAR(1);
  v_old       JSONB;
  v_new       JSONB;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_op        := 'I';
    v_new       := to_jsonb(NEW);
    v_old       := NULL;
    v_record_id := NEW.id;
    v_tenant_id := NEW.tenant_id;
  ELSIF TG_OP = 'UPDATE' THEN
    v_op        := 'U';
    v_old       := to_jsonb(OLD);
    v_new       := to_jsonb(NEW);
    v_record_id := NEW.id;
    v_tenant_id := NEW.tenant_id;
  ELSE
    v_op        := 'D';
    v_old       := to_jsonb(OLD);
    v_new       := NULL;
    v_record_id := OLD.id;
    v_tenant_id := OLD.tenant_id;
  END IF;

  INSERT INTO crm.audit_log (
    tenant_id, table_name, record_id, operation,
    changed_by_id, old_data, new_data,
    ip_address, session_id
  ) VALUES (
    v_tenant_id,
    TG_TABLE_NAME,
    v_record_id,
    v_op,
    (current_setting('app.current_user_id', TRUE))::uuid,
    v_old,
    v_new,
    (current_setting('app.client_ip', TRUE))::inet,
    current_setting('app.session_id', TRUE)
  );

  RETURN COALESCE(NEW, OLD);
END;
$$;

-- ── Attach audit triggers to all core tables ─────────────────
DO $$
DECLARE
  tbl TEXT;
  tables TEXT[] := ARRAY[
    'account','contact','lead','opportunity','opportunity_contact_role',
    'product','pricebook','pricebook_entry',
    'quote','quote_line_item',
    'contract','contract_line_item','contract_line_item_seat',
    'clearing_house'
  ];
BEGIN
  FOREACH tbl IN ARRAY tables LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_audit_%1$s
       AFTER INSERT OR UPDATE OR DELETE ON crm.%1$s
       FOR EACH ROW EXECUTE FUNCTION crm.fn_audit_trigger()',
      tbl
    );
  END LOOP;
END$$;

-- ── HOW TO USE IN YOUR APPLICATION ───────────────────────────
-- In addition to the tenant_id, set these session vars for full audit:
--
--   SET LOCAL app.current_tenant_id = 'tenant-uuid';
--   SET LOCAL app.current_user_id   = 'user-uuid';
--   SET LOCAL app.client_ip         = '192.168.1.100';
--   SET LOCAL app.session_id        = 'session-token-or-request-id';
--
-- Query recent changes to an account:
--   SELECT * FROM crm.audit_log
--   WHERE tenant_id = 'tenant-uuid'
--     AND table_name = 'account'
--     AND record_id  = 'account-uuid'
--   ORDER BY changed_at DESC;
-- ─────────────────────────────────────────────────────────────
