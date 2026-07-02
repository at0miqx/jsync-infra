output "server_fqdn" {
  description = "FQDN of the MySQL Flexible Server (private DNS)."
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "server_name" {
  description = "Name of the MySQL Flexible Server resource."
  value       = azurerm_mysql_flexible_server.main.name
}

output "db_name" {
  description = "Name of the created database."
  value       = azurerm_mysql_flexible_database.main.name
}

output "db_admin_username" {
  description = "MySQL administrator username."
  value       = azurerm_mysql_flexible_server.main.administrator_login
}

output "db_password" {
  description = "Generated MySQL admin password."
  value       = random_password.db.result
  sensitive   = true
}
