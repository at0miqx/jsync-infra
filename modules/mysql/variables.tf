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

variable "db_admin_username" {
  type    = string
}

variable "db_admin_password" {
  type = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "jsync"
}

variable "sku_name" {
  description = "MySQL Flexible Server SKU (e.g. 'B_Standard_B2s')."
  type        = string
  default     = "B_Standard_B2s"
}

variable "mysql_version" {
  type    = string
  default = "8.0.21"
}

variable "storage_gb" {
  type    = number
  default = 20
}

variable "tags" {
  type    = map(string)
  default = {}
}
