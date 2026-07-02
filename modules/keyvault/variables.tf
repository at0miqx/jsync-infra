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

variable "server_principal_id" {
  description = "Object ID of the server Container App managed identity."
  type        = string
}

variable "client_principal_id" {
  description = "Object ID of the client Container App managed identity."
  type        = string
}

variable "db_password" {
  description = "MySQL admin password to store as a secret."
  type        = string
  sensitive   = true
}

variable "db_admin_username" {
  description = "MySQL admin username."
  type        = string
}

variable "db_name" {
  description = "MySQL database name."
  type        = string
}

variable "mysql_fqdn" {
  description = "Fully qualified domain name of the MySQL server."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
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
  description = "Application admin password."
  type        = string
  sensitive   = true
  default     = ""
}
