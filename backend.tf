### NOTE
# The backend configuration is loaded by Terraform extremely early, before
# the core of Terraform can be initialized. This is necessary because the backend
# dictates the behavior of that core. The core is what handles interpolation
# processing. Because of this, interpolations cannot be used in backend
# configuration.

# This file is therefore a placeholder for structural and display purposes,
# but is overridden by backend_override.tf (which is not checked in to source control)
# when interacting with the live environment
terraform {
  backend "azurerm" {
    storage_account_name = "<storage account>"
    container_name       = "<container name>"
    key                  = "sre-ref-implementation.tfstate"
    access_key           = "<access key>"
  }
}
