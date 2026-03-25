# AWS Infrastructure as Code Lab — Terraform

Multi-tier AWS architecture provisioned entirely through Terraform.

---

## Architecture Diagram

```
                        ┌─────────────────────────────────────────────────────┐
                        │                   AWS Cloud (us-east-1)             │
                        │                                                     │
                        │  ┌───────────────────────────────────────────────┐  │
                        │  │              VPC  10.0.0.0/16                 │  │
                        │  │                                               │  │
  Internet              │  │  ┌─────────────────────────────────────────┐  │  │
     │                  │  │  │     Public Subnet  10.0.1.0/24  (AZ-a) │  │  │
     │    ┌──────┐      │  │  │                                         │  │  │
     ├───▶│  IGW │──────┼──┼──┤   ┌──────────┐      ┌──────────┐      │  │  │
     │    └──────┘      │  │  │   │  EC2 #1  │      │  EC2 #2  │      │  │  │
     │                  │  │  │   │ (web/app) │      │ (web/app) │      │  │  │
     │                  │  │  │   └──────────┘      └──────────┘      │  │  │
     │                  │  │  │        │                                │  │  │
     │                  │  │  │   ┌────┴────┐                          │  │  │
     │                  │  │  │   │ NAT GW  │                          │  │  │
     │                  │  │  └───┴─────────┴──────────────────────────┘  │  │
     │                  │  │        │                                      │  │
     │                  │  │  ┌─────┴───────────────────────────────────┐  │  │
     │                  │  │  │  Private Subnets (AZ-a & AZ-b)         │  │  │
     │                  │  │  │     10.0.10.0/24  &  10.0.11.0/24      │  │  │
     │                  │  │  │                                         │  │  │
     │                  │  │  │           ┌──────────────┐              │  │  │
     │                  │  │  │           │  RDS (PgSQL) │              │  │  │
     │                  │  │  │           │  Port 5432   │              │  │  │
     │                  │  │  │           └──────────────┘              │  │  │
     │                  │  │  └─────────────────────────────────────────┘  │  │
     │                  │  └───────────────────────────────────────────────┘  │
     │                  └─────────────────────────────────────────────────────┘

Security Groups:
  EC2-SG  ← inbound SSH (22), HTTP (80), HTTPS (443)
  RDS-SG  ← inbound PostgreSQL (5432) ONLY from EC2-SG
```

---

## Prerequisites

| Tool          | Minimum Version | Install Guide |
|---------------|-----------------|---------------|
| Terraform     | >= 1.5.0        | https://developer.hashicorp.com/terraform/install |
| AWS CLI v2    | >= 2.x          | https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html |
| EC2 Key Pair  | —               | Create in the AWS Console → EC2 → Key Pairs |

### Configure AWS Credentials

```bash
aws configure
# Enter your Access Key ID, Secret Access Key, region (us-east-1), and output format (json).
```

---

## File Structure

```
aws-iac-lab/
├── main.tf            # Provider and backend configuration
├── network.tf         # VPC, subnets, IGW, NAT GW, route tables
├── security.tf        # Security groups (EC2 + RDS)
├── ec2.tf             # Two EC2 instances with user-data
├── rds.tf             # PostgreSQL RDS instance
├── variables.tf       # Input variable declarations
├── terraform.tfvars   # Variable values (gitignored if secrets present)
├── outputs.tf         # Useful outputs after apply
├── .gitignore         # Ignore state, secrets, IDE files
└── README.md          # This file
```

---

## Deploy

### 1. Clone and configure

```bash
git clone <your-repo-url>
cd aws-iac-lab

# Edit terraform.tfvars with your values:
#   - key_pair_name   → your existing EC2 key pair
#   - ssh_allowed_cidr → your public IP (e.g. 203.0.113.42/32)
#   - db_password      → a strong password (min 8 chars)
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview changes

```bash
terraform plan
```

### 4. Apply (provision all resources)

```bash
terraform apply
```

Type `yes` when prompted. Provisioning takes approximately 8-12 minutes (RDS is the slowest).

### 5. Note the outputs

After `apply` completes, Terraform prints public IPs, the RDS endpoint, and ready-to-use SSH commands.

---

## Destroy (tear down all resources)

```bash
terraform destroy
```

Type `yes` when prompted. This removes every resource created by this project.

---

## SSH into an EC2 Instance

Use the output from `terraform apply`, or run:

```bash
# Get the SSH command directly
terraform output ssh_command_web1

# Or manually:
ssh -i ~/.ssh/<your-key>.pem ec2-user@<EC2_PUBLIC_IP>
```

---

## Test RDS Connectivity from EC2

SSH into either EC2 instance first, then connect to PostgreSQL:

```bash
# The psql client is pre-installed via user-data
psql -h <RDS_ENDPOINT> -U dbadmin -d appdb
# Enter the db_password when prompted
```

You can also get the full command from Terraform:

```bash
terraform output rds_test_command
```

### Quick connectivity test (without entering the DB shell):

```bash
pg_isready -h <RDS_ENDPOINT> -p 5432
# Expected: <endpoint>:5432 - accepting connections
```

---

## Security Notes

- **No hardcoded secrets** — DB credentials are declared as `sensitive` variables.
- **terraform.tfvars is gitignored** — secrets never reach version control.
- **RDS is not publicly accessible** — only reachable through the EC2 security group.
- **IMDSv2 enforced** on EC2 instances (prevents SSRF-based credential theft).
- **EBS volumes encrypted** by default.
- **SSH access** should be restricted to your IP via `ssh_allowed_cidr`.

---

## Cost Estimate (free-tier eligible)

| Resource     | Type        | ~Monthly Cost |
|-------------|-------------|---------------|
| EC2 × 2    | t3.micro    | Free tier / ~$15 |
| RDS × 1    | db.t3.micro | Free tier / ~$13 |
| NAT Gateway | —           | ~$32 + data   |
| EIP         | —           | Free (if attached) |

**Tip:** Run `terraform destroy` promptly after completing the lab to avoid charges.
