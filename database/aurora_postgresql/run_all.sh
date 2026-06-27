#!/bin/bash
# =============================================================
# run_all.sh — Run all CRM schema scripts in order
# Usage: ./run_all.sh <aurora-endpoint> <password>
# Example:
#   ./run_all.sh crm-dev-cluster.cluster-xxxx.eu-west-1.rds.amazonaws.com mypassword
# =============================================================

set -e  # exit on first error

HOST=${1:?Usage: ./run_all.sh <aurora-endpoint> <password>}
PASS=${2:?Usage: ./run_all.sh <aurora-endpoint> <password>}
PORT=5432
USER=crm_admin
DB=crm_dev

export PGPASSWORD="$PASS"

SCRIPTS=(
  "02_extensions_and_roles.sql"
  "03_schema_and_enums.sql"
  "04_core_tables.sql"
  "05_revenue_tables.sql"
  "06_indexes.sql"
  "07_rls_policies.sql"
  "08_audit_triggers.sql"
  "09_seed_data.sql"
)

echo "=============================================="
echo "  CRM Aurora Schema Installer"
echo "  Host : $HOST"
echo "  DB   : $DB"
echo "  User : $USER"
echo "=============================================="

for script in "${SCRIPTS[@]}"; do
  echo ""
  echo ">>> Running $script ..."
  psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB" \
       -v ON_ERROR_STOP=1 \
       -f "$script"
  echo "    Done."
done

echo ""
echo "=============================================="
echo "  All scripts completed successfully."
echo "  Your CRM schema is ready in Aurora."
echo "=============================================="

unset PGPASSWORD
