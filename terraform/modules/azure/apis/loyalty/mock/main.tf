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
  name = "loyalty"
}

resource "azurerm_api_management_api" "api" {
  api_management_name = "${var.apim_name}"
  display_name = "Loyalty API"
  name = "loyalty-mock"
  path = ""
  protocols = ["https"]
  resource_group_name = "${var.resource_group_name}"
  revision = "mock"
  version_set_id = data.azurerm_api_management_api_version_set.versionset.id
  version = "mock"
}

resource "azurerm_api_management_product_api" "api" {
  api_management_name = "${var.apim_name}"
  api_name = azurerm_api_management_api.api.name
  resource_group_name = "${var.resource_group_name}"
  product_id = "loyalty"
}


resource "azurerm_api_management_api_operation" "operation" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Member By External ID"
  method = "GET"
  operation_id = "get-member-by-external-id"
  url_template = "/programs/{programCode}/members/{valueOfExternalMemberId}/sources/{memberIdSource}"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
  template_parameter {
    name = "valueOfExternalMemberId"
    required = true
    type = "string"
  }
  template_parameter {
    name = "memberIdSource"
    required = true
    type = "string"
  }
  /*request {
    representation {
      content_type = "application/json"

      example {
        name = "default"
        value = jsonencode({ amount = 10000, orderReference = "CXOEJ2B3RLF41H" })
      }
    }
  }*/
}

resource "azurerm_api_management_api_operation_policy" "operation" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.operation.operation_id
  xml_content = file("mock-get-member-policy.xml")

}