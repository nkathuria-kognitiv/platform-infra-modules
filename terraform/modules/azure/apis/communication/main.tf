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

variable "apim_name" {
}
variable "resource_group_name" {
}



resource "azurerm_api_management_api_version_set" "api" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  display_name = "Communication"
  versioning_scheme = "Segment"
  name = "communication"
}


