variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "acr_login_server" {
  description = "ACR login server hostname."
  type        = string
}

variable "server_image" {
  description = "Full image reference for the server app."
  type        = string
  default     = ""
}

variable "client_image" {
  description = "Full image reference for the client app."
  type        = string
  default     = ""
}

variable "server_cpu" {
  type    = number
  default = 0.5
}

variable "server_memory" {
  type    = string
  default = "1Gi"
}

variable "client_cpu" {
  type    = number
  default = 0.5
}

variable "client_memory" {
  type    = string
  default = "1Gi"
}

variable "mysql_fqdn" {
  description = "FQDN of the MySQL Flexible Server."
  type        = string
}

variable "db_name" {
  type = string
}

variable "db_admin_username" {
  type = string
}

variable "db_password" {
  description = "MySQL admin password (stored as a Container App secret)."
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret."
  type        = string
  sensitive   = true
  default     = ""
}

variable "groq_api_key" {
  description = "GROQ API key."
  type        = string
  sensitive   = true
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password."
  type        = string
  sensitive   = true
  default     = ""
}

variable "admin_password" {
  description = "Application admin account password."
  type        = string
  sensitive   = true
  default     = ""
}

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
  description = "SMTP username / sender email."
  type        = string
  default     = ""
}

variable "smtp_from" {
  description = "Display name for the email sender."
  type        = string
  default     = "JSync Resource Management"
}

variable "admin_username" {
  description = "Application admin username."
  type        = string
  default     = "admin"
}

variable "tags" {
  type    = map(string)
  default = {}
}
