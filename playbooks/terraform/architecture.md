# Terraform Architecture

## Preferred Stack

- Terraform 1.6+
- Remote state in S3 or Terraform Cloud
- State locking with DynamoDB or Terraform Cloud
- Module registry for shared infrastructure
- `tflint` + `tfsec` for validation

## Avoid

- Local state files (committed or otherwise)
- Hardcoded credentials in `.tf` files
- Monolithic configurations with hundreds of resources
- Direct edits to production state
- Skipping `terraform plan` before `apply`

---

## Repository Structure

```
infrastructure/
├── modules/                    # Reusable modules
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── eks-cluster/
│   ├── rds-postgres/
│   └── redis-cluster/
├── environments/
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── production/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf
└── global/
    ├── dns/
    ├── iam/
    └── s3-state/
```

---

## Remote State Configuration

```hcl
# environments/production/backend.tf
terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "acme-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
```

---

## Module Pattern

```hcl
# modules/rds-postgres/variables.tf
variable "identifier" {
  description = "Unique identifier for the RDS instance"
  type        = string
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Storage in GB"
  type        = number
  default     = 20
}

variable "database_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect"
  type        = list(string)
  default     = []
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

```hcl
# modules/rds-postgres/main.tf
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name   = "${var.identifier}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.identifier}/db-password"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_db_instance" "this" {
  identifier = var.identifier
  engine     = "postgres"
  engine_version = "15.4"

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_encrypted = true  # Always encrypt at rest

  db_name  = var.database_name
  username = "dbadmin"
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = !var.deletion_protection
  final_snapshot_identifier = var.deletion_protection ? "${var.identifier}-final" : null

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = var.tags
}
```

```hcl
# modules/rds-postgres/outputs.tf
output "endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "RDS connection endpoint"
}

output "port" {
  value = aws_db_instance.this.port
}

output "database_name" {
  value = aws_db_instance.this.db_name
}

output "password_secret_arn" {
  value       = aws_secretsmanager_secret.db_password.arn
  description = "ARN of the Secrets Manager secret containing the DB password"
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
```

---

## Environment Composition

```hcl
# environments/production/main.tf
module "vpc" {
  source = "../../modules/vpc"

  name               = "production"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = local.tags
}

module "eks" {
  source = "../../modules/eks-cluster"

  cluster_name    = "production"
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      instance_types = ["m5.xlarge"]
      min_size       = 3
      max_size       = 10
      desired_size   = 3
    }
  }

  tags = local.tags
}

module "postgres" {
  source = "../../modules/rds-postgres"

  identifier    = "production-api-db"
  database_name = "api"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids

  allowed_security_group_ids = [module.eks.node_security_group_id]
  instance_class             = "db.r6g.large"
  allocated_storage          = 100
  backup_retention_days      = 14
  deletion_protection        = true

  tags = local.tags
}
```

---

## Tagging Strategy

All resources must be tagged consistently for cost allocation and auditing.

```hcl
# environments/production/main.tf
locals {
  tags = {
    Environment = "production"
    Project     = "my-app"
    Team        = "platform"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
    Owner       = "platform@example.com"
  }
}
```

---

## Linting and Security Scanning

```yaml
# .github/workflows/terraform.yml
- name: tflint
  uses: terraform-linters/setup-tflint@v4
- run: tflint --recursive

- name: tfsec
  uses: aquasecurity/tfsec-action@v1.0.3
  with:
    severity: HIGH

- name: Checkov
  uses: bridgecrewio/checkov-action@master
  with:
    directory: infrastructure/
    framework: terraform
    quiet: true
    soft_fail: false
```

---

## CI/CD Workflow

```yaml
# Plan on PR, Apply on merge to main
jobs:
  plan:
    if: github.event_name == 'pull_request'
    steps:
      - run: terraform init
      - run: terraform validate
      - run: terraform plan -out=tfplan
      - name: Comment plan on PR
        uses: actions/github-script@v7

  apply:
    if: github.ref == 'refs/heads/main'
    steps:
      - run: terraform init
      - run: terraform apply -auto-approve tfplan
```
