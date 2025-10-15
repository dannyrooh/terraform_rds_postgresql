# =========================================================
# Infraestrutura principal: Aurora PostgreSQL + Database Core
# =========================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.20"
    }
  }

  required_version = ">= 1.6.0"
}

# ---------------------------
# Provider AWS
# ---------------------------
provider "aws" {
  region = var.aws_region
}

# ---------------------------
# Módulo: Aurora PostgreSQL + Secrets Manager
# ---------------------------
module "aurora_postgres" {
  source        = "./modules/aurora_postgres"
  environment   = var.environment
  db_name       = var.db_name
  db_username   = var.db_username
  db_password   = var.db_password
  db_port       = var.db_port
  aws_region    = var.aws_region
}

resource "time_sleep" "wait_for_aurora" {
  depends_on = [module.aurora_postgres]
  create_duration = "20s"
}

# =========================================================
# Provider PostgreSQL (para uso nos módulos)
# =========================================================
provider "postgresql" {
  host     = module.aurora_postgres.aurora_endpoint
  port     = var.db_port
  database = module.aurora_postgres.db_name

  # O usuário e senha são obtidos do Secret Manager
  username = var.db_username
  password = var.db_password
  sslmode  = "require"
}

# ---------------------------
# Módulo: Configuração do Banco (schemas, tabelas, grants)
# ---------------------------
module "database_aut_wms" {
  source      = "./modules/database_aut_wms"
  db_host     = module.aurora_postgres.aurora_endpoint
  db_port     = var.db_port
  db_name     = module.aurora_postgres.db_name
  secret_arn  = module.aurora_postgres.aurora_secret_arn
  schema_name = var.db_schema
  environment = var.environment

  # 🔹 Garante que o Secret tenha uma versão válida antes da leitura
  depends_on = [
    module.aurora_postgres.aurora_secret_version_id,
    module.aurora_postgres,
    time_sleep.wait_for_aurora

  ]

}

