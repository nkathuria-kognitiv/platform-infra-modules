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
  name = "esp-mock"
  path = "esp"
  protocols = ["https"]
  resource_group_name = "${var.resource_group_name}"
  revision = "mock"
  version_set_id = data.azurerm_api_management_api_version_set.versionset.id
  version = "mock"
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
  request {
    representation {
      content_type = "application/json"

      example {
        name = "default"
        value = jsonencode({ amount = 10000, orderReference = "CXOEJ2B3RLF41H" })
      }
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "mock_deposit_policy" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.deposit.operation_id
  xml_content = file("mock-deposit-policy.xml")

}