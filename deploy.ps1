<#
.SYNOPSIS
  Executa o pipeline completo de deploy Terraform para o Aurora PostgreSQL + Database.

.DESCRIPTION
  - Gera terraform.tfvars a partir do .env
  - Inicializa e valida Terraform
  - Executa plan e apply
  - Exibe os outputs principais

.AUTHOR
  Dannyrooh Fernandes de Campos
#>

# =============================
# CONFIGURAÇÃO INICIAL
# =============================

$EnvFile = ".env"
$SyncScript = ".\sync-env-to-tfvars.ps1"
$TerraformDir = "."

Write-Host ""
Write-Host "=========================================================" -ForegroundColor DarkCyan
Write-Host " 🚀 Deploy Terraform - Aurora PostgreSQL + Database Core " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor DarkCyan
Write-Host ""

# -----------------------------
# Função para verificar comandos
# -----------------------------
function Check-Command($cmd, $installHint) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "❌ O comando '$cmd' não foi encontrado." -ForegroundColor Red
        Write-Host "   Dica: $installHint" -ForegroundColor Yellow
        exit 1
    }
}

Check-Command terraform "Instale via Chocolatey: choco install terraform"
Check-Command aws "Baixe em: https://aws.amazon.com/cli/"

# -----------------------------
# Gera terraform.tfvars via .env
# -----------------------------
if (Test-Path $SyncScript) {
    Write-Host "📦 Gerando terraform.tfvars a partir do .env..." -ForegroundColor Cyan
    & $SyncScript
} else {
    Write-Host "⚠️  Script $SyncScript não encontrado. Pulei esta etapa." -ForegroundColor Yellow
}

if (-not (Test-Path "$TerraformDir\terraform.tfvars")) {
    Write-Host "❌ terraform.tfvars não encontrado. Abortando deploy." -ForegroundColor Red
    exit 1
}

# -----------------------------
# Entrar no diretório do Terraform
# -----------------------------
$FullPath = Resolve-Path $TerraformDir
if (-not (Test-Path $FullPath)) {
    Write-Host "❌ Diretório Terraform não encontrado: $FullPath" -ForegroundColor Red
    exit 1
}

Push-Location $FullPath
Write-Host "`n📂 Diretório atual: $((Get-Location).Path)" -ForegroundColor Yellow

# -----------------------------
# Inicialização
# -----------------------------
Write-Host "`n🧩 Inicializando Terraform..." -ForegroundColor Cyan
terraform init -input=false
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Erro ao inicializar Terraform." -ForegroundColor Red; Pop-Location; exit 1 }

# -----------------------------
# Validação
# -----------------------------
Write-Host "`n🔍 Validando configuração..." -ForegroundColor Cyan
terraform validate
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Erro de validação no Terraform." -ForegroundColor Red; Pop-Location; exit 1 }

# -----------------------------
# Plano
# -----------------------------
Write-Host "`n🧠 Gerando plano de execução..." -ForegroundColor Cyan
terraform plan -out="tfplan.out"
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Erro ao gerar plano Terraform." -ForegroundColor Red; Pop-Location; exit 1 }

# Confirmação
$confirm = Read-Host "Deseja aplicar o plano agora? (y/n)"
if ($confirm -notin @('y', 'Y')) {
    Write-Host "⏹️  Deploy cancelado pelo usuário." -ForegroundColor Yellow
    Pop-Location
    exit 0
}

# -----------------------------
# Aplicação
# -----------------------------
Write-Host "`n🚀 Aplicando plano Terraform..." -ForegroundColor Green
terraform apply -auto-approve tfplan.out
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao aplicar infraestrutura." -ForegroundColor Red
    Pop-Location
    exit 1
}

# -----------------------------
# Outputs
# -----------------------------
Write-Host "`n📤 Capturando outputs..." -ForegroundColor Cyan
$Outputs = terraform output -json | ConvertFrom-Json

$Endpoint  = $Outputs.aurora_cluster_endpoint.value
$SecretArn = $Outputs.aurora_secret_arn.value
$Schema    = $Outputs.db_schema.value

Write-Host "`n✅ Deploy concluído com sucesso!" -ForegroundColor Green
Write-Host "--------------------------------------------"
Write-Host "🔹 Aurora Endpoint : $Endpoint"
Write-Host "🔹 Secret ARN       : $SecretArn"
Write-Host "🔹 Database Schema  : $Schema"
Write-Host "--------------------------------------------"

# -----------------------------
# Finalização
# -----------------------------
Pop-Location
Write-Host "`n🏁 Deploy finalizado. Diretório restaurado." -ForegroundColor Yellow
