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

data azurerm_resource_group "rsg"{
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

variable "keyvault_rsg_name" {
}

data "azurerm_key_vault" "keyvault" {
  name = "${var.keyvaultname}"
  resource_group_name = "${var.keyvault_rsg_name}"
}

resource "azurerm_api_management" "apim" {
  location            = data.azurerm_resource_group.rsg.location
  name                = var.apim_name
  publisher_email     = var.apim_publisher_email
  publisher_name      = var.apim_publisher_name 
  resource_group_name = data.azurerm_resource_group.rsg.name
  sku_name            = var.apim_sku
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_custom_domain" "apim" {
  api_management_id = azurerm_api_management.apim.id

  gateway{
    host_name = "${var.custom_domain_host_name}"
    key_vault_id  = "https://${var.keyvaultname}.vault.azure.net/secrets/${var.certificate_name}"
  }


}

resource "azurerm_api_management_named_value" "containername" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "containername"
  value = "${var.containername}"
  display_name = "containername"
}

resource "azurerm_api_management_named_value" "storageaccountname" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "storageaccountname"
  value = "${var.storageaccountname}"
  display_name = "storageaccountname"
}

resource "azurerm_api_management_named_value" "keyvaultname" {
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  #count = "${length(var.named_values)}"
  name  = "keyvaultname"
  value = "${var.keyvaultname}"
  display_name = "keyvaultname"
}


/*resource "azurerm_api_management_named_value" "api_key"{
  resource_group_name = data.azurerm_resource_group.rsg.name
  api_management_name = azurerm_api_management.apim.name
  name = "${var.api_key_name}"
  display_name = "${var.api_key_name}"
  secret = true
  value_from_key_vault{
    secret_id ="https://${var.keyvaultname}.vault.azure.net/secrets/${var.api_key_name}"
  }
}*/



resource "azurerm_key_vault_access_policy" "keyvault_apim_policy" {
  key_vault_id = data.azurerm_key_vault.keyvault.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_api_management.apim.identity.0.principal_id

  secret_permissions = [
    "Get"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]
}

output "system_managed_identity" {
  value = azurerm_api_management.apim.identity.0.principal_id
}

data azurerm_storage_account "storageaccount"{
  resource_group_name = "${var.resource_group_name}"
  name = "${var.storageaccountname}"
}

resource "azurerm_role_assignment" "apim_storageaccount_access" {
  scope = data.azurerm_storage_account.storageaccount.id
  principal_id = azurerm_api_management.apim.identity.0.principal_id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "apim_keyvault_access" {
  scope = data.azurerm_key_vault.keyvault.id
  principal_id = azurerm_api_management.apim.identity.0.principal_id
  role_definition_name = "Key Vault Reader"
}


#Health Probe API
resource "azurerm_api_management_api" "apiHealthProbe" {
  name                = "health-probe"
  resource_group_name = "${var.resource_group_name}"
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Health probe"
  path                = "health-probe"
  protocols           = ["https"]

  subscription_key_parameter_names  {
    header = "AppKey"
    query = "AppKey"
  }

  import {
  content_format = "swagger-json"
  content_value  = <<JSON
        {
            "swagger": "2.0",
            "info": {
                "version": "1.0.0",
                "title": "Health probe"
            },
            "host": "not-used-direct-response",
            "basePath": "/",
            "schemes": [
                "https"
            ],
            "consumes": [
                "application/json"
            ],
            "produces": [
                "application/json"
            ],
            "paths": {
                "/": {
                    "get": {
                        "operationId": "get-ping",
                        "responses": {}
                    }
                }
            }
        }
      JSON
  }
}

# set api level policy
resource "azurerm_api_management_api_policy" "apiHealthProbePolicy" {
api_name            = azurerm_api_management_api.apiHealthProbe.name
api_management_name = azurerm_api_management.apim.name
resource_group_name = "${var.resource_group_name}"

xml_content = <<XML
    <policies>
      <inbound>
        <return-response>
            <set-status code="200" />
        </return-response>
        <base />
      </inbound>
    </policies>
  XML
}

resource "azurerm_api_management_policy" "apim_all_apis_policy" {
  xml_content = templatefile("apim_all_apis_policy.xml", {"tenant_id"="${var.tenant_id}", "apim_app_display_name"= "${var.apim_app_display_name}"})
api_management_id = azurerm_api_management.apim.id
}
