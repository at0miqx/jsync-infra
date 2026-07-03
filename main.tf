data "azurerm_client_config" "current" {}

locals {
  # Common tags applied to every resource
  common_tags = {
    project     = var.prefix
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ─── Resource Group ───────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# ─── Networking ───────────────────────────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_address_space  = var.vnet_address_space
  aca_subnet_prefix   = var.aca_subnet_prefix
  mysql_subnet_prefix = var.mysql_subnet_prefix

  tags = local.common_tags
}

# ─── ACR ──────────────────────────────────────────────────────────────────────
# Created before Container Apps so we can pass the login_server to the apps.
# AcrPull role assignments are done in this file (below) AFTER Container Apps
# are created, to avoid a circular module reference.

module "acr" {
  source = "./modules/acr"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# ─── MySQL ────────────────────────────────────────────────────────────────────

module "mysql" {
  source = "./modules/mysql"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password
  db_name             = var.db_name
  sku_name            = var.mysql_sku_name
  mysql_version       = var.mysql_version
  storage_gb          = var.mysql_storage_gb
  delegated_subnet_id = module.networking.mysql_subnet_id
  private_dns_zone_id = module.networking.mysql_private_dns_zone_id

  tags = local.common_tags
}

# ─── Container Apps ───────────────────────────────────────────────────────────

module "container_apps" {
  source = "./modules/container_apps"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  aca_subnet_id       = module.networking.aca_subnet_id

  acr_login_server = module.acr.login_server

  server_image  = var.server_image
  client_image  = var.client_image
  server_cpu    = var.server_cpu
  server_memory = var.server_memory
  client_cpu    = var.client_cpu
  client_memory = var.client_memory

  mysql_fqdn        = module.mysql.server_fqdn
  db_name           = var.db_name
  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password

  # Application secrets
  jwt_secret     = var.jwt_secret
  groq_api_key   = var.groq_api_key
  smtp_password  = var.smtp_password
  admin_password = var.admin_password

  # SMTP + admin config
  smtp_host      = var.smtp_host
  smtp_port      = var.smtp_port
  smtp_user      = var.smtp_user
  smtp_from      = var.smtp_from
  admin_username = var.admin_username

  tags = local.common_tags

  depends_on = [module.mysql, module.acr]
}

# ─── AcrPull role assignments ─────────────────────────────────────────────────
# Defined here (not inside the acr module) to break the circular dependency:
#   acr module needs no principal IDs → container_apps can reference acr first.

resource "azurerm_role_assignment" "server_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.container_apps.server_principal_id
}

resource "azurerm_role_assignment" "client_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.container_apps.client_principal_id
}

# ─── Key Vault ────────────────────────────────────────────────────────────────

module "keyvault" {
  source = "./modules/keyvault"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  server_principal_id = module.container_apps.server_principal_id
  client_principal_id = module.container_apps.client_principal_id

  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password
  db_name           = var.db_name
  mysql_fqdn        = module.mysql.server_fqdn


  # Application secrets
  jwt_secret     = var.jwt_secret
  groq_api_key   = var.groq_api_key
  smtp_password  = var.smtp_password
  admin_password = var.admin_password

  tags = local.common_tags

  depends_on = [module.container_apps, module.mysql, module.acr]
}

import {
  to = module.keyvault.azurerm_key_vault_access_policy.terraform_sp
  id = "${module.keyvault.key_vault_id}/objectId/${data.azurerm_client_config.current.object_id}"
}
