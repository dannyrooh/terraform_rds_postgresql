variable "db_host" {
  description = "Endpoint do Aurora PostgreSQL"
  type        = string
}

variable "db_port" {
  description = "Porta de conexão do banco"
  type        = number
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "secret_arn" {
  description = "ARN do Secret Manager com as credenciais do banco"
  type        = string
}

variable "schema_name" {
  description = "Nome do schema a ser criado"
  type        = string
}

variable "environment" {
  description = "Ambiente atual (dev, staging, prod)"
  type        = string
}

