# 🚀 Terraform AWS Aurora PostgreSQL Serverless v2 Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-v1.6.0+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Aurora%20Serverless%20v2-FF9900?logo=amazonaws&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen)
![Last Commit](https://img.shields.io/github/last-commit/dannyrooh/terraform_rds_postgresql)

Infraestrutura completa em **Terraform** para implantação de **Aurora PostgreSQL Serverless v2** na **AWS**, com suporte a ambientes **dev/staging/prod**, **VPC pública/privada**, **Secrets Manager**, **Security Groups** e **auto scaling** configurável.

---

## 📘 Visão Geral

O projeto provisiona automaticamente:

- 🌐 **VPC** com subnets e rotas públicas/privadas  
- 🔒 **Security Groups** com acesso PostgreSQL (porta 5432)  
- 🧩 **Aurora PostgreSQL Serverless v2** com escalonamento automático (0.5 a 4 ACUs)  
- 🔐 **AWS Secrets Manager** para credenciais e endpoint  
- ⚙️ **Módulos Terraform reutilizáveis** (`aurora_postgres`, `database_aut_wms`)  

Ideal para aplicações **serverless**, **APIs Fastify/Lambda**, **ECS** ou **microserviços** que precisem de banco de dados relacional escalável.

---

## ⚙️ Pré-requisitos

- Terraform >= 1.6.0  
- AWS CLI configurado (`aws configure`)  
- Conta AWS com permissões de RDS, VPC, Secrets Manager  
- PowerShell (Windows) ou bash (Linux/Mac)

---

## 🔐 Configuração do `.env`

Crie um arquivo `.env` na raiz do projeto com:

```bash
AWS_REGION=us-east-1
ENVIRONMENT=dev
DB_NAME=aut_wms
DB_USERNAME=admin
DB_PASSWORD=SenhaForte123!
DB_PORT=5432
```

> ⚠️ O `.env` **não deve ser versionado** — ele já está incluído no `.gitignore`.

---

## 🚀 Deploy da infraestrutura

```bash
terraform init
terraform plan -var "environment=dev"
terraform apply -auto-approve -var "environment=dev"
```

---

## 🧨 Destruir a infraestrutura

```bash
.\destroy.ps1 -Environment "dev" -AutoApprove
```

O script executa `terraform destroy` e remove `.terraform`, `.tfstate` e `.lock.hcl`.

---

## 🧩 Tabela de Variáveis Principais

| Variável | Tipo | Descrição |
|-----------|------|------------|
| `environment` | string | Define o ambiente (dev, staging, prod) |
| `aws_region` | string | Região AWS de deploy |
| `db_name` | string | Nome do banco PostgreSQL |
| `db_username` | string | Usuário administrador do banco |
| `db_password` | string | Senha do banco (armazenada no Secrets Manager) |
| `db_port` | number | Porta do PostgreSQL (padrão 5432) |

---

## 📊 Custo Mensal Estimado *(Outubro 2025)*

| Ambiente | Descrição | USD/mês | BRL/mês (≈5,65) |
|-----------|------------|----------|-----------------|
| 🧪 **DEV** | 0.5 ACU 24x7, 20 GB | ~US$ 50 | ≈ R$ 280 |
| ⚙️ **STAGING** | 1 ACU, 50 GB, I/O moderado | ~US$ 110 | ≈ R$ 620 |
| 🚀 **PROD** | 2 ACU, 100 GB, I/O alto | ~US$ 220 | ≈ R$ 1 240 |

Inclui: compute, storage, I/O, backup e 1 segredo no Secrets Manager.  
Não inclui custos de rede ou serviços externos (ex: Lambda, CloudWatch).

---

## 📦 Exemplo de Saída (`terraform apply`)

```
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

aurora_endpoint = "aurora-cluster-dev.cluster-abcdefghijk.us-east-1.rds.amazonaws.com"
aurora_secret_arn = "arn:aws:secretsmanager:us-east-1:1234567890:secret:aurora-postgres-dev"
```

---

## 🧠 Boas Práticas Implementadas

- ✅ Infra-as-Code modular (módulos `aurora_postgres`, `database_aut_wms`)  
- 🔐 Secrets armazenados no **AWS Secrets Manager**  
- 🌍 Subnets públicas em `dev`, privadas em `prod`  
- 🧩 Variáveis e outputs versionados  
- 🧹 `.gitignore` robusto (evita `.terraform/`, `.tfstate`, `.env`)  
- ⚙️ Scripts PowerShell (`destroy.ps1`) para automação segura  

---

## 👨‍💻 Autor

**Dannyrooh Fernandes de Campos**  
Engenheiro de Software • Cloud & DevOps Architect  
[GitHub](https://github.com/dannyrooh)

---

## 🛡️ Licença

Distribuído sob a licença **MIT**. Veja `LICENSE` para detalhes.
