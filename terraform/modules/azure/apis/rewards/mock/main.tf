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
  name = "rewards"
}

resource "azurerm_api_management_api" "api" {
  api_management_name = "${var.apim_name}"
  display_name = "Rewards Gateway"
  name = "rewards-gateway-mock"
  path = "rewards-gateway"
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
  product_id = "rewards"
}



resource "azurerm_api_management_api_operation" "post_click" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Create Post Member Click"
  method = "POST"
  operation_id = "create-post-member-click"
  url_template = "/programs/{programCode}/rewards/offers/{offerId}/clicks"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
  template_parameter {
    name = "offerId"
    required = true
    type = "string"
  }

  request {
    representation {
      content_type = "application/json"

      /*example {
        name = "default"
        value = jsonencode({ amount = 10000, orderReference = "CXOEJ2B3RLF41H" })
      }*/

    }
  }
  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation_policy" "post_click" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.post_click.operation_id
  xml_content = file("mock-post-click.xml")
}


resource "azurerm_api_management_api_operation" "active_offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get All Active Offers"
  method = "GET"
  operation_id = "get-all-active-offers"
  url_template = "/programs/{programCode}/rewards/offers"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }

  request {
    representation {
      content_type = "application/json"
    }
  }
  response {
    status_code = 200
    description = ""
    representation {
      content_type = "application/json"
      # TODO Update the schema defnition for this resource schema_id =
      example {
        name = "default"
        value = jsonencode({offers={offer="asdf"}})
      }
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "active_offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.active_offers.operation_id
  xml_content = file("mock-get-active-offers-policy.xml")
}

resource "azurerm_api_management_api_operation" "get_clicks" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Member Clicks"
  method = "GET"
  operation_id = "get-member-clicks"
  url_template = "/programs/{programCode}/rewards/clicks/members/{valueOfExternalMemberId}/sources/{sourceId}"
  template_parameter {
    name = "programCode"
    required = true
    type = ""
    values = [""]
  }
  template_parameter {
    name = "valueOfExternalMemberId"
    required = true
    type = "string"
  }
  template_parameter {
    name = "sourceId"
    required = true
    type = "string"
  }

  response {
    status_code = 200
  }

}

resource "azurerm_api_management_api_operation_policy" "get_clicks" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get_clicks.operation_id
  xml_content = file("mock-get-member-clicks-policy.xml")
}

resource "azurerm_api_management_api_operation" "get_transaction" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Member Transactions"
  method = "GET"
  operation_id = "get-member-transactions"
  url_template = "/programs/{programCode}/rewards/transactions/members/{valueOfExternalMemberId}/sources/{sourceId}"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
    values = [""]
  }
  template_parameter {
    name = "valueOfExternalMemberId"
    required = true
    type = "string"
  }
  template_parameter {
    name = "sourceId"
    required = true
    type = "string"
  }
  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation" "get-program-member-offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Program Member Offers"
  method = "GET"
  operation_id = "get-program-member-offers"
  url_template = "/programs/{programCode}/rewards/merchants/{merchantId}/offers"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
  template_parameter {
    name = "merchantId"
    required = true
    type = "string"
  }
}

resource "azurerm_api_management_api_operation_policy" "get-program-member-offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-program-member-offers.operation_id
  xml_content = file("mock-get-program-member-offers-policy.xml")
}


resource "azurerm_api_management_api_operation" "get-merchant-categories" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Program Merchant Categories"
  method = "GET"
  operation_id = "get-merchants"
  url_template = "/programs/{programCode}/rewards/merchantCategories"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
    default_value = "testProgram"
  }

}

resource "azurerm_api_management_api_operation_policy" "get-merchant-categories" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-merchant-categories.operation_id
  xml_content = file("mock-get-merchants-categories-policy.xml")
}

resource "azurerm_api_management_api_operation" "get-program-merchant-list" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Program Merchant List"
  method = "GET"
  operation_id = "get-program-merchant-list"
  url_template = "/programs/{programCode}/rewards/merchants"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
}

resource "azurerm_api_management_api_operation_policy" "get-program-merchant-list" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-program-merchant-list.operation_id
  xml_content = file("mock-get-merchant-list-policy.xml")
}
