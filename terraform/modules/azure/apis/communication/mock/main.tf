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

data "azurerm_api_management_api_version_set" versionset{
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  name = "communication"
}

resource "azurerm_api_management_api" "api" {
  api_management_name = "${var.apim_name}"
  display_name = "Communication"
  name = "communication-mock"
  path = "communications"
  protocols = ["https"]
  resource_group_name = "${var.resource_group_name}"
  revision = "mock"
  version_set_id = data.azurerm_api_management_api_version_set.versionset.id
  version = "mock"
  subscription_key_parameter_names {
    header = "Ocp-Apim-Subscription-Key"
    query = "subscription-key"
  }
}

resource "azurerm_api_management_product_api" "api" {
  api_management_name = "${var.apim_name}"
  api_name = azurerm_api_management_api.api.name
  resource_group_name = "${var.resource_group_name}"
  product_id = "communication"
}

resource "azurerm_api_management_api_operation" "operation" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Member Email  - Lookup Member Info"
  method = "POST"
  operation_id = "member-email-lookup-member-info"
  url_template = "/programs/{programCode}/members/{externalMemberId}/source/{source}/emails"

  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
  template_parameter {
    name = "externalMemberId"
    required = true
    type = "string"
  }
  template_parameter {
    name = "source"
    required = true
    type = "string"
  }
}

resource "azurerm_api_management_api_operation_policy" "operation_policy" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.operation.operation_id
  xml_content = file("mock-communication-policy.xml")

}