output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault (used by Container Apps to reference secrets)."
  value       = azurerm_key_vault.main.vault_uri
}

output "db_password_secret_id" {
  description = "Versioned secret ID of the db-password secret."
  value       = azurerm_key_vault_secret.db_password.id
}

output "db_connection_string_secret_id" {
  description = "Versioned secret ID of the db-connection-string secret."
  value       = azurerm_key_vault_secret.db_connection_string.id
}
