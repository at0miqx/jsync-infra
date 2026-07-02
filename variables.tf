# ─── Core ────────────────────────────────────────────────────────────────────

variable "prefix" {
  description = "Short name prefix applied to every resource name (e.g. 'jsync')."
  type        = string
  default     = "jsync"
}

variable "environment" {
  description = "Deployment environment label (e.g. 'prod', 'staging', 'dev')."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for all resources (must be allowed by your subscription policy)."
  type        = string
  default     = "southindia"
}

# ─── Database ─────────────────────────────────────────────────────────────────

variable "db_name" {
  description = "Name of the MySQL database to create inside the Flexible Server."
  type        = string
  default     = "jsync"
}

variable "db_admin_username" {
  description = "Administrator username for the MySQL Flexible Server."
  type        = string
  default     = "jsyncadmin"
}

variable "mysql_sku_name" {
  description = "SKU name for the MySQL Flexible Server (e.g. 'B_Standard_B2s')."
  type        = string
  default     = "B_Standard_B2s"
}

variable "mysql_version" {
  description = "MySQL version to use."
  type        = string
  default     = "8.0.21"
}

variable "mysql_storage_gb" {
  description = "Allocated storage for MySQL in gigabytes."
  type        = number
  default     = 20
}

# ─── Container Apps ───────────────────────────────────────────────────────────

variable "server_image" {
  description = "Full ACR image reference for the server (e.g. 'acrjsyncprod.azurecr.io/server:latest'). Leave empty on first apply — updated by the app CI/CD pipeline."
  type        = string
  default     = ""
}

variable "client_image" {
  description = "Full ACR image reference for the client (e.g. 'acrjsyncprod.azurecr.io/client:latest'). Leave empty on first apply — updated by the app CI/CD pipeline."
  type        = string
  default     = ""
}

variable "server_cpu" {
  description = "CPU allocation for the server Container App (Consumption plan supports 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0)."
  type        = number
  default     = 0.5
}

variable "server_memory" {
  description = "Memory allocation for the server Container App (must match CPU; e.g. '1Gi' for 0.5 CPU)."
  type        = string
  default     = "1Gi"
}

variable "client_cpu" {
  description = "CPU allocation for the client Container App."
  type        = number
  default     = 0.5
}

variable "client_memory" {
  description = "Memory allocation for the client Container App."
  type        = string
  default     = "1Gi"
}

# ─── Networking ───────────────────────────────────────────────────────────────

variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aca_subnet_prefix" {
  description = "Address prefix for the Container Apps Environment subnet (min /23 required)."
  type        = string
  default     = "10.0.0.0/23"
}

variable "mysql_subnet_prefix" {
  description = "Address prefix for the MySQL Flexible Server delegated subnet."
  type        = string
  default     = "10.0.2.0/24"
}

# ─── Application Secrets (sensitive) ─────────────────────────────────────────
# Set these via GitHub Secrets → passed as -var flags by CI/CD.
# Never commit actual values here.

variable "jwt_secret" {
  description = "Secret key used to sign JWTs in the server application."
  type        = string
  sensitive   = true
  default     = ""
}

variable "groq_api_key" {
  description = "GROQ API key used by the server."
  type        = string
  sensitive   = true
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password for sending emails."
  type        = string
  sensitive   = true
  default     = ""
}

variable "admin_password" {
  description = "Initial admin account password for the application."
  type        = string
  sensitive   = true
  default     = ""
}

# ─── Application Config (non-sensitive) ──────────────────────────────────────

variable "smtp_host" {
  description = "SMTP server hostname."
  type        = string
  default     = "smtp.gmail.com"
}

variable "smtp_port" {
  description = "SMTP server port."
  type        = string
  default     = "587"
}

variable "smtp_user" {
  description = "SMTP username (typically the sender email address)."
  type        = string
  default     = ""
}

variable "smtp_from" {
  description = "Display name used as the email sender."
  type        = string
  default     = "JSync Resource Management"
}

variable "admin_username" {
  description = "Initial admin account username for the application."
  type        = string
  default     = "admin"
}

variable "next_public_app_name" {
  description = "App name baked into the Next.js client bundle at build time (NEXT_PUBLIC_APP_NAME)."
  type        = string
  default     = "Resource Manager Engine"
}
