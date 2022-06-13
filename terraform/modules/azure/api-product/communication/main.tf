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

variable "resource_group_name" {
}
variable "apim_name" {
}

output "product_id" {
  value = module.product_mee.product_id
}

module "product_mee" {
  source = "../"

  resource_group_name = "${var.resource_group_name}"
  apim_name="${var.apim_name}"

  product_display_name = "Communication"
  product_id = "communication"
  published = false
  product_description = "Communication Product"
}

