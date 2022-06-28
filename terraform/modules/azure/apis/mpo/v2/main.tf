terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.10.0"
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
  name = "mpo"
}

resource "azurerm_api_management_api" "api" {
  api_management_name = "${var.apim_name}"
  display_name = "MPO"
  name = "mpo-v2"
  path = "mpo"
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
resource "azurerm_api_management_api_schema" "deposit_schema" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  schema_id =  "Deposit"
  content_type = "application/json"
  value               = file("Deposit-Definiton.json")
}


variable "post_deposit_schema_id" {
  default = ""
}
variable "post_deposit_type_name" {
  default = ""
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
    values = ["NAB"]
  }
  template_parameter {
    name = "memberId"
    required = true
    type = "string"
    values = ["87cc6708-d91a-4ecc-af98-17b405b2373a", "ef7cf9c0-2443-4e3e-b0f5-76883ce6f794", "3e45936a-a65f-4e1b-8430-b70045a9dfb3"]
  }
  request {
    representation {
      schema_id = "${var.post_deposit_schema_id}"
      type_name = "${var.post_deposit_type_name}"
      content_type = "application/json"
      example{
        name="default"
        value=jsonencode({amount=200,currency="NABRWDS",dataPartner="NAB",description="Alla test", interactionType="value",originalTransactionId="1234567890"})
      }

    }
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
  request {
    query_parameter {
      name = "fields"
      required = false
      type = ""
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "members_policy" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.members.operation_id
  xml_content = file("v2-members-info-policy.xml")
}

resource "azurerm_api_management_api_policy" "api_policy" {
  api_management_name = "${var.apim_name}"
  api_name = azurerm_api_management_api.api.name
  resource_group_name = "${var.resource_group_name}"
  xml_content = file("mpo-v2-api-policy.xml")
}


