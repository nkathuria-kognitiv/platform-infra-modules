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
  name = var.rsg_name
}

resource "azurerm_api_management" "apim" {
  location            = data.azurerm_resource_group.rsg.location
  name                = var.apim_name
  publisher_email     = var.apim_publisher_email
  publisher_name      = var.apim_publisher_name 
  resource_group_name = data.azurerm_resource_group.rsg.name
  sku_name            = var.apim_sku
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
  name  = "containername"
  value = "${var.storageaccountname}"
  display_name = "storageaccountname"
}

resource "azurerm_api_management_named_value" "storageaccountname" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "containername"
  value = "${var.storageaccountname}"
  display_name = "storageaccountname"
}



resource "azurerm_api_management_named_value" "keyvaultname" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "containername"
  value = "${var.keyvaultname}"
  display_name = "keyvaultname"
}



