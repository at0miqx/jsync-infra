output "login_server" {
  description = "ACR login server hostname (e.g. acrjsyncprod.azurecr.io)."
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
  description = "Resource ID of the ACR."
  value       = azurerm_container_registry.main.id
}

output "admin_username" {
  description = "ACR admin username."
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "ACR admin password."
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}
