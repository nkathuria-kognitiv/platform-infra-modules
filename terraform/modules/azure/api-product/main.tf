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

# Should be passed automatically by terragrunt. Dont need to specify each time.
variable "apim_name" {}
variable "resource_group_name" {}

#Following variables must be specfied, as these are mandatory.
variable "product_id" {}
variable "product_display_name" {}
variable "product_description" { default = "Not Specified"}

variable "published" { default = true}

variable "subscription_required" {
  default = true
}
variable "approval_required" {
  default = false
}
resource "azurerm_api_management_product" "product" {
  api_management_name = "${var.apim_name}"
  display_name = "${var.product_display_name}"
  product_id = "${var.product_id}"
  published = "${var.published}"
  resource_group_name = "${var.resource_group_name}"
  subscription_required = "${var.subscription_required}"
  approval_required = "${var.approval_required}"
  description = "${var.product_description}"
}

output "product_id" {
  value = azurerm_api_management_product.product.product_id
}