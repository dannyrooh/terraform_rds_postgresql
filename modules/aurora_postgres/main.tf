# =========================================================
# Módulo: Aurora PostgreSQL Serverless v2 com Secrets Manager
# =========================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ---------------------------
# Dados de disponibilidade
# ---------------------------
data "aws_availability_zones" "available" {}

# =========================================================
# VPC e Rede
# =========================================================
resource "aws_vpc" "aurora_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aurora-vpc-${var.environment}"
  }
}

# Internet Gateway (apenas para dev)
resource "aws_internet_gateway" "aurora_igw" {
  vpc_id = aws_vpc.aurora_vpc.id

  tags = {
    Name = "aurora-igw-${var.environment}"
  }
}

# Route Table pública (apenas dev)
resource "aws_route_table" "aurora_public_rt" {
  vpc_id = aws_vpc.aurora_vpc.id

  tags = {
    Name = "aurora-public-rt-${var.environment}"
  }
}

# Rota pública padrão
resource "aws_route" "aurora_public_route" {
  route_table_id         = aws_route_table.aurora_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aurora_igw.id
}

# =========================================================
# Subnets
# =========================================================
resource "aws_subnet" "aurora_subnet_a" {
  vpc_id                  = aws_vpc.aurora_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.environment == "dev" ? true : false

  tags = {
    Name = "aurora-subnet-a-${var.environment}"
  }
}

resource "aws_subnet" "aurora_subnet_b" {
  vpc_id                  = aws_vpc.aurora_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.environment == "dev" ? true : false

  tags = {
    Name = "aurora-subnet-b-${var.environment}"
  }
}

# Associa subnets à route table pública (apenas dev)
resource "aws_route_table_association" "aurora_subnet_a_assoc" {
  subnet_id      = aws_subnet.aurora_subnet_a.id
  route_table_id = aws_route_table.aurora_public_rt.id
}

resource "aws_route_table_association" "aurora_subnet_b_assoc" {
  subnet_id      = aws_subnet.aurora_subnet_b.id
  route_table_id = aws_route_table.aurora_public_rt.id
}

# =========================================================
# Grupo de subnets para o Aurora
# =========================================================
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group-${var.environment}"
  subnet_ids = [
    aws_subnet.aurora_subnet_a.id,
    aws_subnet.aurora_subnet_b.id
  ]

  tags = {
    Name = "aurora-subnet-group-${var.environment}"
  }
}

# =========================================================
# Security Group
# =========================================================
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg-${var.environment}"
  description = "Permitir acesso PostgreSQL"
  vpc_id      = aws_vpc.aurora_vpc.id

  ingress {
    description = "PostgreSQL access"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restringir em produção
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aurora-sg-${var.environment}"
  }
}

# =========================================================
# Aurora PostgreSQL Serverless v2
# =========================================================
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-cluster-${var.environment}"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  storage_encrypted       = true
  skip_final_snapshot     = true
  deletion_protection     = false

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 4
  }

  tags = {
    Name        = "aurora-cluster-${var.environment}"
    Environment = var.environment
  }

  depends_on = [
    aws_internet_gateway.aurora_igw,
    aws_route.aurora_public_route
  ]
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier          = "aurora-instance-${var.environment}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = var.environment == "dev" ? true : false

  tags = {
    Name = "aurora-instance-${var.environment}"
  }

  depends_on = [
    aws_internet_gateway.aurora_igw,
    aws_route.aurora_public_route,
    aws_route_table_association.aurora_subnet_a_assoc,
    aws_route_table_association.aurora_subnet_b_assoc
  ]
}

# =========================================================
# AWS Secrets Manager
# =========================================================
resource "aws_secretsmanager_secret" "aurora_secret" {
  name        = "aurora-postgres-${var.environment}"
  description = "Credenciais e endpoint do Aurora PostgreSQL (${var.environment})"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "aurora_secret_version" {
  secret_id = aws_secretsmanager_secret.aurora_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_rds_cluster.aurora_cluster.endpoint
    port     = var.db_port
    database = var.db_name
    engine   = "aurora-postgresql"
  })
}
