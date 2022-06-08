terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
  backend "azurerm" {}
}


provider "azurerm" {
  features {}
}

data azurerm_resource_group "rsg"{
  name = var.resource_group_name
}

resource "azurerm_api_management" "apim" {
  location            = data.azurerm_resource_group.rsg.location
  name                = var.apim_name
  publisher_email     = var.apim_publisher_email
  publisher_name      = var.apim_publisher_name 
  resource_group_name = data.azurerm_resource_group.rsg.name
  sku_name            = var.apim_sku
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_named_value" "containername" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "containername"
  value = "${var.containername}"
  display_name = "containername"
}

resource "azurerm_api_management_named_value" "storageaccountname" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "storageaccountname"
  value = "${var.storageaccountname}"
  display_name = "storageaccountname"
}

resource "azurerm_api_management_named_value" "keyvaultname" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "keyvaultname"
  value = "${var.keyvaultname}"
  display_name = "keyvaultname"
}


resource "azurerm_api_management_named_value" "api_key"{
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  name = var.api_key_name
  display_name = var.api_key_name
  secret = true
  value_from_key_vault{
    secret_id ="https://${var.keyvaultname}.vault.azure.net/secrets/${var.api_key_name}"
  }
}

resource "azurerm_api_management_policy" "apim_all_apis_policy" {
  xml_content = templatefile("apim_all_apis_policy.xml", {"tenant_id"="${var.tenant_id}", "apim_app_display_name"= "${var.apim_app_display_name}"})
  api_management_id = azurerm_api_management.apim.id
}
