
resource "azurerm_resource_group" "monitoring_storage" {
  name     = "icpsre-monitoring-storage"
  location = "West Europe"
}

resource "azurerm_storage_account" "monitoring_storage" {
  name                     = "icpsremonstorage"
  resource_group_name      = "${azurerm_resource_group.monitoring_storage.name}"
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "monitoring_storage" {
  name                  = "monitoring-storage"
  resource_group_name   = "${azurerm_resource_group.monitoring_storage.name}"
  storage_account_name  = "${azurerm_storage_account.monitoring_storage.name}"
  container_access_type = "private"
}

output "monitoring_storage_account" {
  value = "${azurerm_storage_account.monitoring_storage.id}"
}

output "monitoring_storage_account_key" {
  value = "${azurerm_storage_account.monitoring_storage.primary_access_key}"
}

output "monitoring_storage_container" {
  value = "${azurerm_storage_container.monitoring_storage.name}"
}

output "monitoring_storage_endpoint" {
  value = "${azurerm_storage_account.monitoring_storage.primary_file_endpoint}"
}
