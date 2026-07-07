# ─── Log Analytics workspace (required by Container App Environment) ──────────

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# ─── Container App Environment ────────────────────────────────────────────────
# No VNet integration — apps can reach the internet (to pull images from MCR/ACR)
# and still communicate internally via DNS within the same environment.

resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.prefix}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id   = var.aca_subnet_id

  lifecycle {
    ignore_changes = [
      infrastructure_resource_group_name,
    ]
  }

  tags = var.tags
}

# ─── Server Container App ─────────────────────────────────────────────────────

resource "azurerm_container_app" "server" {
  name                         = "${var.prefix}-server"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [var.acr_pull_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.acr_pull_identity_id
  }

  template {
    min_replicas = 1
    max_replicas = 5

    container {
      name   = "server"
      image  = var.server_image != "" ? var.server_image : "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = var.server_cpu
      memory = var.server_memory

      # ── Database ──────────────────────────────────────────────────────────
      env {
        name  = "PORT"
        value = "8080"
      }
      env {
        name  = "DB_HOST"
        value = var.mysql_fqdn
      }
      env {
        name  = "DB_PORT"
        value = "3306"
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name  = "DB_USER"
        value = var.db_admin_username
      }
      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }

      # ── Application secrets ───────────────────────────────────────────────
      env {
        name        = "JWT_SECRET"
        secret_name = "jwt-secret"
      }
      env {
        name        = "GROQ_API_KEY"
        secret_name = "groq-api-key"
      }
      env {
        name        = "SMTP_PASSWORD"
        secret_name = "smtp-password"
      }
      env {
        name        = "ADMIN_PASSWORD"
        secret_name = "admin-password"
      }

      # ── SMTP config ───────────────────────────────────────────────────────
      env {
        name  = "MTP_HOST"
        value = var.smtp_host
      }
      env {
        name  = "SMTP_PORT"
        value = var.smtp_port
      }
      env {
        name  = "SMTP_USER"
        value = var.smtp_user
      }
      env {
        name  = "SMTP_FROM"
        value = var.smtp_from
      }

      # ── Admin seed account ────────────────────────────────────────────────
      env {
        name  = "ADMIN_USERNAME"
        value = var.admin_username
      }
    }
  }

  secret {
    name  = "db-password"
    value = var.db_admin_password
  }
  secret {
    name  = "jwt-secret"
    value = var.jwt_secret != "" ? var.jwt_secret : "placeholder-set-before-deploy"
  }
  secret {
    name  = "groq-api-key"
    value = var.groq_api_key != "" ? var.groq_api_key : "placeholder-set-before-deploy"
  }
  secret {
    name  = "smtp-password"
    value = var.smtp_password != "" ? var.smtp_password : "placeholder-set-before-deploy"
  }
  secret {
    name  = "admin-password"
    value = var.admin_password != "" ? var.admin_password : "placeholder-set-before-deploy"
  }

  # Internal ingress only — not reachable from the internet
  ingress {
    allow_insecure_connections = true
    external_enabled           = false
    target_port                = 8080

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  tags = var.tags
}

# ─── Client Container App ─────────────────────────────────────────────────────

resource "azurerm_container_app" "client" {
  name                         = "${var.prefix}-client"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [var.acr_pull_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.acr_pull_identity_id
  }

  template {
    min_replicas = 1
    max_replicas = 5

    container {
      name   = "client"
      image  = var.client_image != "" ? var.client_image : "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = var.client_cpu
      memory = var.client_memory

      env {
        name  = "PORT"
        value = "3000"
      }
      env {
        name  = "BACKEND_URL"
        value = "http://${var.prefix}-server"
      }
    }
  }

  # Public ingress
  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  tags = var.tags
}
