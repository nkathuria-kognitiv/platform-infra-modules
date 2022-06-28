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
  name = "communication"
}

data "azurerm_api_management_product" communication{
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  product_id = "communication"
}

resource "azurerm_api_management_api" "api" {
  api_management_name = "${var.apim_name}"
  display_name = "Communication"
  name = "communication-v1"
  path = "communications"
  protocols = ["https"]
  resource_group_name = "${var.resource_group_name}"
  revision = "1"
  version_set_id = data.azurerm_api_management_api_version_set.versionset.id
  version = "v1"
  subscription_key_parameter_names {
    header = "Ocp-Apim-Subscription-Key"
    query = "subscription-key"
  }
}

resource "azurerm_api_management_product_api" "api" {
  api_management_name = "${var.apim_name}"
  api_name = azurerm_api_management_api.api.name
  product_id = data.azurerm_api_management_product.communication.product_id
  resource_group_name = "${var.resource_group_name}"
}

variable "post_email_schema_id" {
  default = ""
}
variable "post_email_type_name" {
  default = ""
}
resource "azurerm_api_management_api_operation" "member-email-lookup-member-info" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Member Email  - Lookup Member Info"
  method = "POST"
  operation_id = "member-email-lookup-member-info"
  url_template = "/programs/{programCode}/members/{valueOfExternalMemberId}/source/{source}/emails"

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
    name = "source"
    required = true
    type = "string"
  }
  request {
    description = "{ \"templateId\":\"5840068\",\n\"details\": {\"merchantName\":\"Apple\",\n            \"transactionDate\": \"2022-05-11T15:25:01\",\n            \"rewardAmount\": \"200\",\n            \"rewardType\" : \"points\",\n            \"currentYear\" : \"2022\"}}"
    representation {
      content_type = "application/json"
      schema_id = "${var.post_email_schema_id}"
      type_name = "${var.post_email_type_name}"

      example {
        name="default"
        value = jsonencode({templateId="5840068", details= {merchantName="Apple",transactionDate="2022-05-11T15:25:01" , rewardAmount="200", rewardType="points",currentYear="2022"}})

        #value ="{ \"templateId\":\"5840068\",\n\"details\": {\"merchantName\":\"Apple\",\n            \"transactionDate\": \"2022-05-11T15:25:00\",\n            \"rewardAmount\": \"200\",\n            \"rewardType\" : \"points\",\n            \"currentYear\" : \"2022\"}}"
      }
    }
  }
}

resource "azurerm_api_management_api_policy" "api_policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  xml_content = file("v1-communication-api-policy.xml")
}

resource "azurerm_api_management_api_operation_policy" "member-email-lookup-member-info" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.member-email-lookup-member-info.operation_id
  xml_content = file("v1-member-email-lookup-member-info-policy.xml")
}


