output "aurora_cluster_endpoint" {
  description = "Endpoint do Aurora PostgreSQL"
  value       = module.aurora_postgres.aurora_endpoint
}

output "aurora_secret_arn" {
  description = "ARN do Secret Manager do banco"
  value       = module.aurora_postgres.aurora_secret_arn
}

output "db_schema" {
  description = "Schema criado no banco"
  value       = module.database_aut_wms.schema_name
}
