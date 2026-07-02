output "client_url" {
  description = "Public URL for the jsync frontend application."
  value       = module.container_apps.client_url
}

output "server_fqdn" {
  description = "Internal FQDN of the backend Container App (only reachable within the VNet)."
  value       = module.container_apps.server_fqdn
}

output "acr_login_server" {
  description = "ACR login server — used in CI/CD to push and reference images."
  value       = module.acr.login_server
}

output "key_vault_uri" {
  description = "Key Vault URI for manual secret retrieval."
  value       = module.keyvault.key_vault_uri
}

output "resource_group_name" {
  description = "Name of the main application resource group."
  value       = azurerm_resource_group.main.name
}

output "container_app_environment_domain" {
  description = "Default domain of the Container App Environment."
  value       = module.container_apps.environment_default_domain
}

output "mysql_server_name" {
  description = "Name of the MySQL Flexible Server."
  value       = module.mysql.server_name
}
