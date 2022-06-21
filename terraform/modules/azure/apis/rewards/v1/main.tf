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
  name = "rewards"
}

resource "azurerm_api_management_api" "api" {
  api_management_name = "${var.apim_name}"
  display_name = "Rewards Gateway"
  name = "rewards-gateway-v1"
  path = "rewards"
  protocols = ["https"]
  resource_group_name = "${var.resource_group_name}"
  revision = "1"
  version_set_id = data.azurerm_api_management_api_version_set.versionset.id
  version = "v1"
}

resource "azurerm_api_management_product_api" "api" {
  api_management_name = "${var.apim_name}"
  api_name = azurerm_api_management_api.api.name
  resource_group_name = "${var.resource_group_name}"
  product_id = "rewards"
}

resource "azurerm_api_management_api_operation" "get-all-active-offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get All Active Offers"
  description = "Get All Active Offers"
  method = "GET"
  operation_id = "get-all-active-offers"
  url_template = "/programs/{programCode}/rewards/offers"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }

  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation_policy" "get-all-active-offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-all-active-offers.operation_id
  xml_content = file("v1-get-all-active-offers-policy.xml")
}


resource "azurerm_api_management_api_operation" "get-member-clicks" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Member Clicks"
  description = "Get Member Clicks"
  method = "GET"
  operation_id = "get-member-clicks"
  url_template = "/programs/{programCode}/rewards/clicks/members/{valueOfExternalMemberId}/sources/{sourceId}"
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
    name = "sourceId"
    required = true
    type = "string"
  }
  request {
    query_parameter {
      name = "language"
      required = true
      type = "string"
      values = ["en"]
    }
    query_parameter {
      name = "merchantName"
      required = false
      type = "string"
    }
    query_parameter {
      name = "endDate"
      required = false
      type = "date"
    }
    query_parameter {
      name = "startDate"
      required = false
      type = "date"
    }
    query_parameter {
      name = "pageSize"
      required = false
      type = "int"
      values = [100]
    }
    query_parameter {
      name = "pageNumber"
      required = false
      type = "int"
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "get-member-clicks" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-member-clicks.operation_id
  xml_content = file("v1-get-member-clicks-policy.xml")
}

resource "azurerm_api_management_api_operation" "get-member-transactions" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Member Transactions"
  description = "Get Member Transactions"
  method = "GET"
  operation_id = "get-member-transactions"
  url_template = "/programs/{programCode}/rewards/transactions/members/{valueOfExternalMemberId}/sources/{source}"
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
  query_parameter {
    name = "pageNumber"
    required = false
    type = "int"
  }
  query_parameter {
    name = "pageSize"
    required = false
    type = "int"
  }
  query_parameter {
    name = "startDate"
    required = false
    type = "date"
  }
  query_parameter {
    name = "endDate"
    required = false
    type = "date"
  }
  query_parameter {
    name = "merchantName"
    required = false
    type = "string"
  }

  query_parameter {
    name = "language"
    required = true
    type = "string"
    values = ["en"]
  }
}
}

resource "azurerm_api_management_api_operation_policy" "get-member-transactions" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-member-transactions.operation_id
  xml_content = file("v1-get-member-transactions-policy.xml")
}


resource "azurerm_api_management_api_operation" "get-program-member-offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Merchant Offers"
  description = "Get Merchant Offers"
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
  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation_policy" "get-program-member-offers" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-program-member-offers.operation_id
  xml_content = file("v1-get-program-member-offers-policy.xml")
}

resource "azurerm_api_management_api_operation" "get-merchant-categories" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Program Merchant Categories"
  description = "Get Program Merchant Categories"
  method = "GET"
  operation_id = "get-merchant-categories"
  url_template = "/programs/{programCode}/rewards/merchantCategories"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
    values = ["NAB"]
  }
  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation_policy" "get-merchant-categories" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-merchant-categories.operation_id
  xml_content = file("v1-get-merchants-categories-policy.xml")
}

resource "azurerm_api_management_api_operation" "get-merchant-list" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Get Program Merchant List"
  description = "Get Program Merchant List"
  method = "GET"
  operation_id = "get-merchant-list"
  url_template = "/programs/{programCode}/rewards/merchants"
  template_parameter {
    name = "programCode"
    required = true
    type = "string"
  }
  request {
    query_parameter {
      name = "pageNumber"
      required = false
      type = "int"
      default_value = 0
    }
    query_parameter {
      name = "pageSize"
      required = false
      type = "int"
      default_value = 0 # TODO Should be confirmed
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "get-merchant-list" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.get-merchant-list.operation_id
  xml_content = file("v1-get-merchant-list-policy.xml")
}

/*resource "api_management_api_schema" "request" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  schema_id           = "request"
  content_type        = "application/json"
  value               = file("api_management_api_request_schema.json")
}*/


resource "azurerm_api_management_api_operation" "create-post-member-click" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  display_name = "Post Member Click"
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
    type="string"
  }

  request {
    representation {
      content_type = "application/json"
      example {
        name = "default"
        value = jsonencode({memberId={source="LID",value="123456"},language="en",categoryId="123"})
        # TODO Update this value
      }
      #type="request"
      #schema_id = api_management_api_schema.request.schema_id
    }
  }
}



resource "azurerm_api_management_api_operation_policy" "create-post-member-click" {
  api_management_name = "${var.apim_name}"
  resource_group_name = "${var.resource_group_name}"
  api_name = azurerm_api_management_api.api.name
  operation_id = azurerm_api_management_api_operation.create-post-member-click.operation_id
  xml_content = file("v1-create-post-member-click-policy.xml")
}

resource "azurerm_api_management_api_policy" "api_policy" {
  api_management_name = "${var.apim_name}"
  api_name = azurerm_api_management_api.api.name
  resource_group_name = "${var.resource_group_name}"
  xml_content = file("rewards-v1-api-policy.xml")
}
