<#
.SYNOPSIS
  Sincroniza variáveis do arquivo .env com o arquivo terraform.tfvars

.DESCRIPTION
  Lê o arquivo .env e gera (ou atualiza) o arquivo terraform.tfvars,
  preservando comentários e linhas em branco.
  Converte apenas as variáveis válidas conforme o mapeamento definido.

.AUTHOR
  Dannyrooh Fernandes de Campos
#>

# =============================
# CONFIGURAÇÃO INICIAL
# =============================

$EnvFile = ".env"
$TfVarsFile = "terraform.tfvars"

if (-not (Test-Path $EnvFile)) {
    Write-Host "❌ Arquivo .env não encontrado no diretório atual." -ForegroundColor Red
    exit 1
}

Write-Host "📖 Lendo arquivo .env..." -ForegroundColor Cyan
$envLines = Get-Content $EnvFile -Encoding UTF8

# =============================
# MAPEAMENTO .env → .tfvars
# =============================

$mapping = @{
    "ENVIRONMENT"          = "environment"
    "AWS_REGION"           = "aws_region"
    "AWS_ACCOUNT_ID"       = "aws_account_id"

    "PG_DB_PORT"           = "db_port"
    "PG_DB_NAME"           = "db_name"
    "PG_DB_SCHEMA"         = "db_schema"
    "PG_DB_USER"           = "db_username"
    "PG_DB_PASSWORD"       = "db_password"

    "DYNAMODB_TABLE_NAME"  = "dynamodb_table_name"
}

# =============================
# PROCESSAMENTO DAS LINHAS
# =============================

$tfvarsContent = @()

foreach ($line in $envLines) {
    $trimmed = $line.Trim()

    # Linha vazia → mantém igual
    if ([string]::IsNullOrWhiteSpace($trimmed)) {
        $tfvarsContent += ""
        continue
    }

    # Linha de comentário → mantém igual
    if ($trimmed.StartsWith("#")) {
        $tfvarsContent += $trimmed
        continue
    }

    # Linha com variável = valor
    if ($trimmed -match "^[A-Za-z0-9_]+=") {
        $parts = $trimmed -split "=", 2
        if ($parts.Length -eq 2) {
            $envKey = $parts[0].Trim()
            $envValue = $parts[1].Trim()

            if ($mapping.ContainsKey($envKey)) {
                $tfKey = $mapping[$envKey]

                # Detecta se é número
                if ($envValue -match '^[0-9]+$') {
                    $tfvarsContent += "$tfKey = $envValue"
                } else {
                    $escaped = $envValue.Replace('"', '\"')
                    $tfvarsContent += "$tfKey = `"$escaped`""
                }
            }
        }
        continue
    }

    # Qualquer outra linha (incomum) é copiada literalmente
    $tfvarsContent += $line
}

# =============================
# ESCRITA DO ARQUIVO .tfvars
# =============================

$header = @(
    "# ========================================================="
    "# Arquivo gerado automaticamente a partir de .env"
    "# Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    "# ========================================================="
    ""
)

$finalContent = $header + $tfvarsContent

$finalContent | Out-File -Encoding utf8 -FilePath $TfVarsFile -Force

Write-Host "✅ Arquivo $TfVarsFile atualizado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📄 Prévia do conteúdo gerado:"
Write-Host "--------------------------------------------"
Get-Content $TfVarsFile
Write-Host "--------------------------------------------"
