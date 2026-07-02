resource "random_string" "mysql_suffix" {
  length  = 6
  special = false
  upper   = false

  # Only regenerate if the base name changes
  keepers = {
    prefix      = var.prefix
    environment = var.environment
  }
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-${var.prefix}-${var.environment}-${random_string.mysql_suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.db_admin_username
  administrator_password = random_password.db.result
  sku_name               = var.sku_name
  version                = var.mysql_version

  storage {
    auto_grow_enabled = true
    size_gb           = var.storage_gb
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  lifecycle {
    # Azure auto-assigns the availability zone on creation.
    # The zone cannot be changed in-place, so we ignore any drift.
    ignore_changes = [zone, high_availability[0].standby_availability_zone]
  }

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "main" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# ─── Firewall rules ───────────────────────────────────────────────────────────
# Allow all Azure-internal traffic (includes Container Apps, Azure services).
# The 0.0.0.0 rule is the Azure convention for "allow Azure services".

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "ON"
}
