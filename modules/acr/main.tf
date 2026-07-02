resource "azurerm_container_registry" "main" {
  name                = "acr${var.prefix}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"

  # Admin credentials are needed so Container Apps can pull images.
  # We store them in Key Vault immediately after creation.
  admin_enabled = true

  tags = var.tags
}
# NOTE: AcrPull role assignments for Container App managed identities are
# defined in the root main.tf to avoid a circular module dependency.
