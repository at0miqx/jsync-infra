#!/usr/bin/env bash
# bootstrap.sh — Run ONCE to create the Terraform remote state backend.
# This script creates a dedicated resource group + storage account for tfstate,
# separate from the application resource group so it survives `terraform destroy`.
#
# Prerequisites: az CLI logged in (`az login`) with sufficient permissions.
# Usage: bash bootstrap/bootstrap.sh

set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
TFSTATE_RG="rg-jsync-tfstate"
LOCATION="southindia"  # Change if your subscription doesn't allow southindia

# Storage account names must be 3-24 chars, lowercase letters + numbers only.
# Make this globally unique by appending a short random suffix.
SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 6)
STORAGE_ACCOUNT_NAME="stjsynctfstate${SUFFIX}"
CONTAINER_NAME="tfstate"

echo "==> Creating resource group: ${TFSTATE_RG}"
az group create \
  --name "${TFSTATE_RG}" \
  --location "${LOCATION}" \
  --output none

echo "==> Creating storage account: ${STORAGE_ACCOUNT_NAME}"
az storage account create \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --resource-group "${TFSTATE_RG}" \
  --location "${LOCATION}" \
  --sku "Standard_LRS" \
  --kind "StorageV2" \
  --min-tls-version "TLS1_2" \
  --allow-blob-public-access false \
  --output none

echo "==> Creating blob container: ${CONTAINER_NAME}"
az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --auth-mode login \
  --output none

echo ""
echo "=========================================================="
echo "  Bootstrap complete!"
echo "=========================================================="
echo ""
echo "  Update backend.tf with:"
echo "    storage_account_name = \"${STORAGE_ACCOUNT_NAME}\""
echo ""
echo "  Then run:"
echo "    terraform init \\"
echo "      -backend-config=\"resource_group_name=${TFSTATE_RG}\" \\"
echo "      -backend-config=\"storage_account_name=${STORAGE_ACCOUNT_NAME}\" \\"
echo "      -backend-config=\"container_name=${CONTAINER_NAME}\" \\"
echo "      -backend-config=\"key=jsync.terraform.tfstate\""
echo ""
echo "  Add these as GitHub Secrets (infra repo):"
echo "    TF_STATE_RESOURCE_GROUP=${TFSTATE_RG}"
echo "    TF_STATE_STORAGE_ACCOUNT=${STORAGE_ACCOUNT_NAME}"
echo "    TF_STATE_CONTAINER=${CONTAINER_NAME}"
echo "=========================================================="
