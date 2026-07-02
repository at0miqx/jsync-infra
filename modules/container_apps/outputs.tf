output "server_principal_id" {
  description = "Object ID of the server Container App's system-assigned managed identity."
  value       = azurerm_container_app.server.identity[0].principal_id
}

output "client_principal_id" {
  description = "Object ID of the client Container App's system-assigned managed identity."
  value       = azurerm_container_app.client.identity[0].principal_id
}

output "server_fqdn" {
  description = "Internal FQDN of the server Container App."
  value       = azurerm_container_app.server.ingress[0].fqdn
}

output "client_fqdn" {
  description = "Public FQDN of the client Container App."
  value       = azurerm_container_app.client.ingress[0].fqdn
}

output "client_url" {
  description = "Public URL for the client application."
  value       = "https://${azurerm_container_app.client.ingress[0].fqdn}"
}

output "environment_id" {
  description = "Resource ID of the Container App Environment."
  value       = azurerm_container_app_environment.main.id
}

output "environment_default_domain" {
  description = "Default domain of the Container App Environment."
  value       = azurerm_container_app_environment.main.default_domain
}
