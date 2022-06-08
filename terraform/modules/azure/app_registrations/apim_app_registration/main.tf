terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.99.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "=2.22.0"
    }
  }
  backend "azurerm" {}
}

provider "azuread" {
}

provider "azurerm" {
  features {}
}


resource "azuread_application" "apim_app_registration" {

  display_name = "${var.apim_app_display_name}"
  identifier_uris  = ["api://${var.apim_app_display_name}"]

  app_role {
    id = "ae299053-cb8a-4805-9f81-362e1024222f"
    allowed_member_types = [ "Application"]
    description = "This role allow application to access all APIM APIs."
    display_name = "api.all"
    enabled = true
    value = "api.all"
  }

  app_role {
    id = "a0847551-b04c-4c26-a1e1-8a87078c64a2"
    allowed_member_types = [ "Application"]
    description = "Access to all esp APIs"
    display_name = "esp.all"
    enabled = true
    value = "esp.all"
  }

  app_role {
    id = "2703afb1-9c12-465d-b27c-2ad5ccd5ee6e"
    allowed_member_types = [ "Application"]
    description = "This role allows aplication to access to APIs to update member info"
    display_name = "loyalty.member.write"
    enabled = true
    value = "loyalty.member.write"
  }

  app_role {
    id = "aa1b436e-4df7-48a6-8bf0-2dcec3de740a"
    allowed_member_types = [ "Application"]
    description = "This role allows the third party apps to read the member Information."
    display_name = "loyalty.member.read"
    enabled = true
    value = "loyalty.member.read"
  }

  app_role {
    id = "e9fb9830-4728-4d19-88d7-aacd6a3e57e1"
    allowed_member_types = [ "Application"]
    description = "This role allows client application to  access to all rewards (Affiliate Mall) APIs"
    display_name = "rewards.all"
    enabled = true
    value = "rewards.all"
  }

  api{
    oauth2_permission_scope{
      id = "29908299-1837-4a70-82d9-7f2834d93bc2"
      admin_consent_description = "Access to PUT and POST APIs"
      admin_consent_display_name ="Write APIs"
      user_consent_display_name = "Access to PUT and POST APIs"
      user_consent_description = "Access to PUT and POST APIs"
      enabled  =true
      type                       = "User"
      value = "write"
    }
    oauth2_permission_scope{
      id = "619db479-cd99-42bf-9c6d-86683ff6bef7"
      admin_consent_description = "Access to GET APIs"
      admin_consent_display_name ="Read APIs"
      user_consent_display_name = "Access to GET APIs"
      user_consent_description = "Access to GET APIs"
      enabled  =true
      type                       = "User"
      value = "read"
    }
  }
}



resource "azuread_application" "pmp_app_registration" {

  display_name = "${var.pmp_app_display_name}"
  required_resource_access {
    resource_app_id = azuread_application.apim_app_registration.application_id
    resource_access {
      id = "ae299053-cb8a-4805-9f81-362e1024222f"
      type = "Role"
    }
    resource_access {
      id = "aa1b436e-4df7-48a6-8bf0-2dcec3de740a"
      type = "Role"
    }
    resource_access {
      id = "2703afb1-9c12-465d-b27c-2ad5ccd5ee6e"
      type = "Role"
    }
    resource_access {
      id = "29908299-1837-4a70-82d9-7f2834d93bc2"
      type = "Scope"
    }
    resource_access {
      id = "619db479-cd99-42bf-9c6d-86683ff6bef7"
      type = "Scope"
    }
  }
}


resource "azuread_application_password" "pmp_secret" {
  application_object_id = azuread_application.pmp_app_registration.object_id
}


