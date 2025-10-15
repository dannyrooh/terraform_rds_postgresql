<#
.SYNOPSIS
  Executa o Terraform Destroy de forma segura e automatizada.

.DESCRIPTION
  Este script destrói todos os recursos criados pelo Terraform
  (Aurora PostgreSQL Serverless, VPC, Secrets Manager, etc.),
  confirmando antes a operação e limpando a infraestrutura local.

.AUTHOR
  Dannyrooh Fernandes de Campos
  github.com/dannyrooh
#>

param(
    [string]$Environment = "dev",
    [switch]$AutoApprove
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🚨 Terraform Destroy - Ambiente: $Environment"
Write-Host "=============================================" -ForegroundColor Cyan

# Verifica se o Terraform está instalado
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Terraform não encontrado no PATH." -ForegroundColor Red
    Write-Host "Instale o Terraform e tente novamente."
    exit 1
}

# Confirmação interativa (caso não tenha --AutoApprove)
if (-not $AutoApprove) {
    $confirm = Read-Host "Tem certeza que deseja DESTRUIR todos os recursos Terraform? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "⚠️  Operação cancelada pelo usuário." -ForegroundColor Yellow
        exit 0
    }
}

# Inicializa Terraform (se necessário)
Write-Host "`n🔄 Inicializando Terraform..."
terraform init -upgrade

# Exibe plano de destruição antes da execução
Write-Host "`n📋 Gerando plano de destruição..."
terraform plan -destroy -var "environment=$Environment" -out=tfplan-destroy.out

# Executa o destroy (com ou sem confirmação automática)
if ($AutoApprove) {
    Write-Host "`n💣 Executando terraform destroy --auto-approve..." -ForegroundColor Yellow
    terraform destroy -auto-approve -var "environment=$Environment"
} else {
    Write-Host "`n💣 Executando terraform destroy (modo interativo)..." -ForegroundColor Yellow
    terraform destroy -var "environment=$Environment"
}

# Limpa arquivos temporários
Write-Host "`n🧹 Limpando artefatos locais..." -ForegroundColor Cyan
Remove-Item -Recurse -Force ".terraform" -ErrorAction SilentlyContinue
Remove-Item -Force ".terraform.lock.hcl","tfplan-destroy.out","terraform.tfstate","terraform.tfstate.backup" -ErrorAction SilentlyContinue

Write-Host "`n✅ Infraestrutura destruída e limpa com sucesso!" -ForegroundColor Green
