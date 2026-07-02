data "azurerm_client_config" "current" {}

# ─── Key Vault ────────────────────────────────────────────────────────────────

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.prefix}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # disable for hackathon ease of re-create

  tags = var.tags
}

# ─── Access policy: Terraform SP (to write secrets during apply) ──────────────

resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover",
  ]
}

# ─── Access policy: server Container App managed identity ─────────────────────

resource "azurerm_key_vault_access_policy" "server_app" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.server_principal_id

  secret_permissions = ["Get", "List"]
}

# ─── Access policy: client Container App managed identity ─────────────────────

resource "azurerm_key_vault_access_policy" "client_app" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.client_principal_id

  secret_permissions = ["Get", "List"]
}

# ─── Secrets ──────────────────────────────────────────────────────────────────

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

resource "azurerm_key_vault_secret" "db_connection_string" {
  name         = "db-connection-string"
  value        = "mysql://${var.db_admin_username}:${var.db_password}@${var.mysql_fqdn}:3306/${var.db_name}"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

# ─── Application secrets ──────────────────────────────────────────────────────
# Only created when a non-empty value is supplied (so first apply without
# these values doesn't fail — add them before the first real deployment).

resource "azurerm_key_vault_secret" "jwt_secret" {
  count        = var.jwt_secret != "" ? 1 : 0
  name         = "jwt-secret"
  value        = var.jwt_secret
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

resource "azurerm_key_vault_secret" "groq_api_key" {
  count        = var.groq_api_key != "" ? 1 : 0
  name         = "groq-api-key"
  value        = var.groq_api_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

resource "azurerm_key_vault_secret" "smtp_password" {
  count        = var.smtp_password != "" ? 1 : 0
  name         = "smtp-password"
  value        = var.smtp_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

resource "azurerm_key_vault_secret" "admin_password" {
  count        = var.admin_password != "" ? 1 : 0
  name         = "admin-password"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}
