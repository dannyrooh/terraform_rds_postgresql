# =========================================================
# Outputs do módulo Aurora PostgreSQL
# =========================================================

output "aurora_endpoint" {
  description = "Endpoint principal do cluster Aurora PostgreSQL"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_secret_arn" {
  description = "ARN do Secret Manager com as credenciais do banco"
  value       = aws_secretsmanager_secret.aurora_secret.arn
}

output "db_name" {
  description = "Nome do banco de dados criado"
  value       = var.db_name
}

output "aurora_secret_version_id" {
  description = "ID da versão atual do Secret Manager"
  value       = aws_secretsmanager_secret_version.aurora_secret_version.version_id
}