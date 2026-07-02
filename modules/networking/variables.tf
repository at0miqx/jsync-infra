variable "prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "environment" {
  description = "Deployment environment label."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR block for the VNet."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aca_subnet_prefix" {
  description = "CIDR for the Container Apps Environment subnet (min /23)."
  type        = string
  default     = "10.0.0.0/23"
}

variable "mysql_subnet_prefix" {
  description = "CIDR for the MySQL Flexible Server delegated subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
