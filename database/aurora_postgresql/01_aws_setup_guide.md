# AWS Aurora PostgreSQL — Dev/Sandbox Setup Guide
## Region: eu-west-1 (Ireland) | Cost target: < $10/month at zero traffic

---

## PART 1 — Pre-flight checklist

Before touching the AWS console, confirm you have:
- [ ] AWS account with IAM user that has `AmazonRDSFullAccess` + `AmazonVPCFullAccess`
- [ ] AWS CLI installed locally (`aws --version`)
- [ ] `psql` installed locally (PostgreSQL client)

---

## PART 2 — VPC & networking (one-time setup)

Aurora must live inside a VPC. We use the default VPC for dev to keep cost and complexity minimal.

### 2.1 Verify your default VPC exists

Open: https://eu-west-1.console.aws.amazon.com/vpc/home?region=eu-west-1#vpcs

You should see a VPC with **"Default VPC: Yes"**. Note its **VPC ID** (e.g. `vpc-0abc1234`).

If no default VPC exists, create one:
```
AWS Console → VPC → Actions → Create Default VPC
```

### 2.2 Create a DB Subnet Group

Aurora requires subnets in at least 2 AZs.

1. Go to: https://eu-west-1.console.aws.amazon.com/rds/home?region=eu-west-1#db-subnet-groups
2. Click **Create DB Subnet Group**
3. Fill in:
   - Name: `crm-dev-subnet-group`
   - Description: `CRM dev Aurora subnet group`
   - VPC: select your default VPC
   - Availability Zones: select **eu-west-1a**, **eu-west-1b**, **eu-west-1c**
   - Subnets: select all subnets shown
4. Click **Create**

### 2.3 Create a Security Group for the DB

1. Go to: https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#SecurityGroups
2. Click **Create Security Group**
3. Fill in:
   - Name: `crm-aurora-dev-sg`
   - Description: `Allow Postgres access to Aurora dev cluster`
   - VPC: your default VPC
4. **Inbound rules** → Add rule:
   - Type: `PostgreSQL`
   - Port: `5432`
   - Source: `My IP` (your current IP — for dev only)
5. Click **Create Security Group**
6. Note the **Security Group ID** (e.g. `sg-0abc1234`)

> **Cost note:** For dev, we allow your IP directly. Never use `0.0.0.0/0` on port 5432.

---

## PART 3 — Create the Aurora Serverless v2 Cluster

This is the most important section. Every choice here affects your bill.

### 3.1 Open the RDS Create wizard

Go to: https://eu-west-1.console.aws.amazon.com/rds/home?region=eu-west-1#launch-dbinstance

### 3.2 Engine selection

| Field | Value |
|---|---|
| **Creation method** | Standard create |
| **Engine type** | Aurora (PostgreSQL-compatible) |
| **Engine version** | Aurora PostgreSQL 16.x (latest) |
| **Edition** | Aurora (PostgreSQL-compatible) |

### 3.3 Templates

Select: **Dev/Test**

> This pre-disables Multi-AZ and some expensive defaults.

### 3.4 Settings

| Field | Value |
|---|---|
| **DB cluster identifier** | `crm-dev-cluster` |
| **Master username** | `crm_admin` |
| **Master password** | Choose a strong password, save in AWS Secrets Manager |
| **Auto generate password** | Yes (recommended — AWS stores it in Secrets Manager) |

### 3.5 Instance configuration — CRITICAL FOR COST

| Field | Value | Reason |
|---|---|---|
| **DB instance class** | Serverless v2 | Scales to zero when idle |
| **Minimum ACUs** | **0.5** | ~$0.09/hr when active, ~$0 when paused |
| **Maximum ACUs** | **4** | Enough for dev; caps your max spend |

> **Cost math:** At 0.5 ACU minimum in eu-west-1:
> - Active (8h/day, 22 days/month): ~$8/month
> - Truly idle (paused): ~$0.10/month storage only
> - Maximum possible (4 ACU × 730h): ~$58/month hard cap

### 3.6 Availability & durability

| Field | Value |
|---|---|
| **Multi-AZ deployment** | **Don't create an Aurora Replica** |

> Saves ~50% — no replica needed for dev.

### 3.7 Connectivity

| Field | Value |
|---|---|
| **VPC** | Your default VPC |
| **DB Subnet group** | `crm-dev-subnet-group` |
| **Public access** | **Yes** (dev only — so you can connect from your laptop) |
| **VPC security group** | Select `crm-aurora-dev-sg` (created in 2.3) |
| **Availability Zone** | No preference |
| **Database port** | 5432 |

> **Security note:** Public access + IP-restricted security group is acceptable for dev.
> Production must use private subnets + VPN/bastion only.

### 3.8 Database authentication

| Field | Value |
|---|---|
| **Authentication** | Password authentication + IAM database authentication |

### 3.9 Additional configuration — COST SAVERS

Expand "Additional configuration":

| Field | Value | Saving |
|---|---|---|
| **Initial database name** | `crm_dev` | Creates the DB automatically |
| **DB cluster parameter group** | default | No change needed |
| **Backup retention** | **1 day** | Minimum — saves storage cost |
| **Backup window** | No preference | |
| **Encryption** | Enable (default, no extra cost) | |
| **Performance Insights** | **Disable** | Saves ~$0/month on free tier but keep clean |
| **Enhanced monitoring** | **Disable** | Saves ~$3.50/month |
| **Auto minor version upgrade** | Enable | |
| **Deletion protection** | **Disable** (dev only) | Easier cleanup |
| **Export logs to CloudWatch** | **Uncheck all** | Saves CloudWatch ingestion cost |

### 3.10 Create the cluster

Click **Create database**. Provisioning takes 5–10 minutes.

---

## PART 4 — Retrieve connection details

Once status shows **Available**:

1. Go to RDS → Clusters → `crm-dev-cluster`
2. Note the **Writer endpoint** (e.g. `crm-dev-cluster.cluster-xxxx.eu-west-1.rds.amazonaws.com`)
3. Retrieve password from Secrets Manager:
   - Go to: https://eu-west-1.console.aws.amazon.com/secretsmanager/home?region=eu-west-1
   - Find the secret named `rds!cluster-...`
   - Click **Retrieve secret value**

---

## PART 5 — Connect and run the schema scripts

### 5.1 Test connection from your terminal

```bash
psql \
  --host=crm-dev-cluster.cluster-xxxx.eu-west-1.rds.amazonaws.com \
  --port=5432 \
  --username=crm_admin \
  --dbname=crm_dev \
  --password
```

Enter the password when prompted. You should see the `crm_dev=#` prompt.

### 5.2 Run scripts in order

```bash
# Run each script in sequence
# Run 03 first to create the schema
psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 03_schema_and_enums.sql

# Then re-run 02 — the schema now exists so the GRANTs will succeed
psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 02_extensions_and_roles.sql


psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 04_core_tables.sql

psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 05_revenue_tables.sql

psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 06_indexes.sql

psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 07_rls_policies.sql

psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 08_audit_triggers.sql

psql -h crm-dev-cluster-instance-1.cf02k0sq0l6x.eu-west-1.rds.amazonaws.com \
  -p 5432 -U crm_admin -d crm_dev \
  -v ON_ERROR_STOP=1 \
  -f 09_seed_data.sql

```

---

## PART 6 — Cost monitoring (important)

Set a billing alert to avoid surprises:

1. Go to: https://us-east-1.console.aws.amazon.com/billing/home#/budgets
2. Click **Create budget** → **Use a template** → **Monthly cost budget**
3. Set amount: **$20** (gives buffer above expected ~$8)
4. Add your email for alerts at 80% and 100%

### To pause the cluster when not in use (saves ~100% compute cost):

```bash
# Stop cluster (saves compute, you still pay storage ~$0.10/GB/month)
aws rds stop-db-cluster \
  --db-cluster-identifier crm-dev-cluster \
  --region eu-west-1

# Start cluster when needed
aws rds start-db-cluster \
  --db-cluster-identifier crm-dev-cluster \
  --region eu-west-1
```

> Aurora automatically restarts after 7 days if stopped (AWS limitation).
> Serverless v2 at 0.5 ACU minimum doesn't truly pause — use stop/start for zero compute cost.

---

## PART 7 — Cleanup (when done with dev)

```bash
# Delete cluster (WARNING: destroys all data)
aws rds delete-db-cluster \
  --db-cluster-identifier crm-dev-cluster \
  --skip-final-snapshot \
  --region eu-west-1
```

---

## Estimated monthly cost summary (eu-west-1)

| Component | Config | Est. cost/month |
|---|---|---|
| Aurora Serverless v2 compute | 0.5 ACU min, 8h/day active | ~$5–8 |
| Aurora storage | < 5 GB at dev volumes | ~$0.50 |
| Aurora I/O | Dev-level read/write | ~$0.50 |
| Backup storage | 1-day retention | ~$0.10 |
| Data transfer | Minimal for dev | ~$0 |
| **Total estimate** | | **~$6–10/month** |

> If you stop the cluster when not in use, compute drops to $0 and total is ~$1/month.
