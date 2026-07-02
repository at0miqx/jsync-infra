# bootstrap.ps1 — Run ONCE to create the Terraform remote state backend.
# This script creates a dedicated resource group + storage account for tfstate,
# separate from the application resource group so it survives `terraform destroy`.
#
# Prerequisites: az CLI logged in (`az login`) with sufficient permissions.
# Usage: .\bootstrap\bootstrap.ps1

$ErrorActionPreference = "Stop"

# ─── Configuration ────────────────────────────────────────────────────────────
$TfstateRg          = "rg-jsync-tfstate"
$Location           = "koreacentral"
$Suffix             = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object { [char]$_ })
$StorageAccountName = "stjsynctfstate$Suffix"
$ContainerName      = "tfstate"

Write-Host "==> Creating resource group: $TfstateRg" -ForegroundColor Cyan
az group create `
  --name $TfstateRg `
  --location $Location `
  --output none

Write-Host "==> Creating storage account: $StorageAccountName" -ForegroundColor Cyan
az storage account create `
  --name $StorageAccountName `
  --resource-group $TfstateRg `
  --location $Location `
  --sku "Standard_LRS" `
  --kind "StorageV2" `
  --min-tls-version "TLS1_2" `
  --allow-blob-public-access false `
  --output none

Write-Host "==> Creating blob container: $ContainerName" -ForegroundColor Cyan
az storage container create `
  --name $ContainerName `
  --account-name $StorageAccountName `
  --auth-mode login `
  --output none

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Bootstrap complete!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Update backend.tf with:"
Write-Host "    storage_account_name = `"$StorageAccountName`""
Write-Host ""
Write-Host "  Then run:"
Write-Host "    terraform init ``"
Write-Host "      -backend-config=`"resource_group_name=$TfstateRg`" ``"
Write-Host "      -backend-config=`"storage_account_name=$StorageAccountName`" ``"
Write-Host "      -backend-config=`"container_name=$ContainerName`" ``"
Write-Host "      -backend-config=`"key=jsync.terraform.tfstate`""
Write-Host ""
Write-Host "  Add these as GitHub Secrets (infra repo):" -ForegroundColor Yellow
Write-Host "    TF_STATE_RESOURCE_GROUP=$TfstateRg"
Write-Host "    TF_STATE_STORAGE_ACCOUNT=$StorageAccountName"
Write-Host "    TF_STATE_CONTAINER=$ContainerName"
Write-Host "==========================================================" -ForegroundColor Green
