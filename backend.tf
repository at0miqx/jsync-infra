terraform {
  backend "azurerm" {
    # These values are filled in by CI/CD via environment variables
    # (ARM_ACCESS_KEY or ARM_SAS_TOKEN), or passed via -backend-config flags.
    # Run bootstrap/bootstrap.sh (or bootstrap.ps1) once to create this
    # storage account before running terraform init.
    resource_group_name  = "rg-jsync-tfstate"
    storage_account_name = "stjsynctfstatenlwkv7"
    container_name       = "tfstate"
    key                  = "jsync.terraform.tfstate"
  }
}
