# 🚀 Terraform AWS Aurora PostgreSQL Serverless v2 Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-v1.6.0+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Aurora%20Serverless%20v2-FF9900?logo=amazonaws&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen)
![Last Commit](https://img.shields.io/github/last-commit/dannyrooh/terraform_rds_postgresql)

Complete **Terraform** infrastructure for deploying **AWS Aurora PostgreSQL Serverless v2** with support for **dev/staging/prod** environments, **public/private VPC**, **Secrets Manager**, **Security Groups**, and dynamic **auto-scaling**.

---

## 📘 Overview

This project automatically provisions:

- 🌐 **VPC** with public/private subnets and routes  
- 🔒 **Security Groups** for PostgreSQL (port 5432)  
- 🧩 **Aurora PostgreSQL Serverless v2** (0.5 to 4 ACUs auto-scaling)  
- 🔐 **AWS Secrets Manager** for credentials and endpoint  
- ⚙️ **Reusable Terraform modules** (`aurora_postgres`, `database_aut_wms`)  

Perfect for **serverless APIs**, **ECS/Fargate**, or **microservice** architectures needing scalable relational databases.

---

## ⚙️ Requirements

- Terraform >= 1.6.0  
- AWS CLI configured (`aws configure`)  
- AWS account with RDS, VPC, and Secrets Manager permissions  
- PowerShell (Windows) or bash (Linux/Mac)

---

## 🔐 `.env` Configuration

Create a `.env` file in the project root:

```bash
AWS_REGION=us-east-1
ENVIRONMENT=dev
DB_NAME=aut_wms
DB_USERNAME=admin
DB_PASSWORD=StrongPassword123!
DB_PORT=5432
```

> ⚠️ The `.env` file **must not be versioned** — it is already in `.gitignore`.

---

## 🚀 Deploy Infrastructure

```bash
terraform init
terraform plan -var "environment=dev"
terraform apply -auto-approve -var "environment=dev"
```

---

## 🧨 Destroy Infrastructure

```bash
.\destroy.ps1 -Environment "dev" -AutoApprove
```

This script safely runs `terraform destroy` and cleans `.terraform`, `.tfstate`, and `.lock.hcl` files.

---

## 🧩 Main Variable Table

| Variable | Type | Description |
|-----------|------|-------------|
| `environment` | string | Environment name (dev, staging, prod) |
| `aws_region` | string | AWS deployment region |
| `db_name` | string | PostgreSQL database name |
| `db_username` | string | Database admin username |
| `db_password` | string | Database password (stored in Secrets Manager) |
| `db_port` | number | PostgreSQL port (default 5432) |

---

## 📊 Estimated Monthly Cost *(October 2025)*

| Environment | Description | USD/month | BRL/month (≈5.65) |
|--------------|-------------|------------|------------------|
| 🧪 **DEV** | 0.5 ACU 24x7, 20 GB | ~US$ 50 | ≈ R$ 280 |
| ⚙️ **STAGING** | 1 ACU, 50 GB, moderate I/O | ~US$ 110 | ≈ R$ 620 |
| 🚀 **PROD** | 2 ACU, 100 GB, high I/O | ~US$ 220 | ≈ R$ 1 240 |

Includes: compute, storage, I/O, backups, and one secret in Secrets Manager.  
Excludes: network transfer or other AWS integrations (Lambda, CloudWatch).

---

## 📦 Example Output (`terraform apply`)

```
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

aurora_endpoint = "aurora-cluster-dev.cluster-abcdefghijk.us-east-1.rds.amazonaws.com"
aurora_secret_arn = "arn:aws:secretsmanager:us-east-1:1234567890:secret:aurora-postgres-dev"
```

---

## 🧠 Implemented Best Practices

- ✅ Modular IaC design (`aurora_postgres`, `database_aut_wms`)  
- 🔐 Secure secrets storage via **AWS Secrets Manager**  
- 🌍 Public subnets for `dev`, private for `prod`  
- 🧩 Versioned variables and outputs  
- 🧹 Robust `.gitignore` (excludes `.terraform/`, `.tfstate`, `.env`)  
- ⚙️ Automated PowerShell scripts (`destroy.ps1`) for safe operations  

---

## 👨‍💻 Author

**Dannyrooh Fernandes de Campos**  
Software Engineer • Cloud & DevOps Architect  
[GitHub](https://github.com/dannyrooh)

---

## 🛡️ License

Distributed under the **MIT License**. See `LICENSE` for details.
