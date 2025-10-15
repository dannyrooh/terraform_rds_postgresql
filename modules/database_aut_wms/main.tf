terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.20"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------------------------------------
# Obter credenciais seguras do Secrets Manager
# -------------------------------------------------
data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.secret_arn
  version_stage = "AWSCURRENT"
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)
}

# -------------------------------------------------
# Criar schema principal
# -------------------------------------------------
resource "postgresql_schema" "core" {
  name  = var.schema_name
  owner = local.db_creds.username
}

