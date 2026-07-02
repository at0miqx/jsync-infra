output "vnet_id" {
  description = "Resource ID of the VNet."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the VNet."
  value       = azurerm_virtual_network.main.name
}

output "aca_subnet_id" {
  description = "Resource ID of the Container Apps subnet."
  value       = azurerm_subnet.aca.id
}

output "mysql_subnet_id" {
  description = "Resource ID of the MySQL delegated subnet."
  value       = azurerm_subnet.mysql.id
}

output "mysql_private_dns_zone_id" {
  description = "Resource ID of the MySQL private DNS zone."
  value       = azurerm_private_dns_zone.mysql.id
}

output "mysql_private_dns_zone_name" {
  description = "Name of the MySQL private DNS zone."
  value       = azurerm_private_dns_zone.mysql.name
}
