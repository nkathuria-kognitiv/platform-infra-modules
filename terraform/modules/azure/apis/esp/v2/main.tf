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
  name = "esp"
}

resource "azurerm_api_management_api" "api" {
  api_management_name = "${var.apim_name}"
  display_name = "ESP"
  name = "esp-v2"
  path = "esp"
  protocols = ["https"]
  resource_group_name = "${var.resource_group_name}"
  revision = "v2"
  version_set_id = data.azurerm_api_management_api_version_set.versionset.id
  version = "v2"
  subscription_key_parameter_names {
    header = "Ocp-Apim-Subscription-Key"
    query = "subscription-key"
  }
}

resource "azurerm_api_management_api_operation" "deposit" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Deposit"
  method = "POST"
  operation_id = "deposit"
  url_template = "/programs/{programCode}/members/{memberId}/deposits"

  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
  template_parameter {
    name = "memberId"
    required = true
    type = "string"
  }
}

resource "azurerm_api_management_api_operation_policy" "deposit_policy" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.deposit.operation_id
  xml_content = file("v2-deposit-policy.xml")

}

resource "azurerm_api_management_api_operation" "members" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Member Info"
  method = "GET"
  operation_id = "member-info"
  url_template = "/programs/{programCode}/members/{memberId}"

  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
  template_parameter {
    name = "memberId"
    required = true
    type = "string"
  }
}

resource "azurerm_api_management_api_operation_policy" "members_policy" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.members.operation_id
  xml_content = file("v2-members-info-policy.xml")
}
