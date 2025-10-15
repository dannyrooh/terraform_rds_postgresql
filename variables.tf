variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_username" {
  description = "Usuário master do banco"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Porta de conexão do banco"
  type        = number
  default     = 5432
}

variable "db_schema" {
  description = "Nome do schema a ser criado"
  type        = string
  default     = "core"
}

variable "aws_account_id" {
  description = "ID da conta AWS (usado para referência cruzada ou tagging)"
  type        = string
  default     = null
}

variable "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB (para integração futura)"
  type        = string
  default     = null
}