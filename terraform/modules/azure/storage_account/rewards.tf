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

variable "resource_group_name" {}
variable "storage_account_name" {}

data azurerm_resource_group "rsg"{
  name = var.resource_group_name
}


resource "azurerm_storage_account" "storage_acount" {
  account_replication_type = "RAGRS"
  account_tier = "Standard"
  location = data.azurerm_resource_group.rsg.location
  name = "${var.storage_account_name}"
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_blob" "storage_acount" {
  name             = "test.txt"
  storage_share_id = azurerm_storage_share.example.id
  source           = "${path.root}/TestFile/test.txt"
  resource_group_name = ""
  storage_account_name = ""
  storage_container_name = ""
}