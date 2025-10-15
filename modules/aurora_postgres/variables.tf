# =========================================================
# Variáveis do módulo Aurora PostgreSQL
# =========================================================

variable "environment" {
  description = "Ambiente de implantação (ex: dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "Região AWS onde o Aurora será criado"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados principal"
  type        = string
}

variable "db_username" {
  description = "Usuário master do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha master do banco de dados (injetada externamente)"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Porta de conexão do banco"
  type        = number
}
