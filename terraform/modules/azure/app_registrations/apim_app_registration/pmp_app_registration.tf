resource "azuread_application" "pmp_app_registration" {
  depends_on = [
    "azuread_application.apim_app_registration"]
  display_name = "${var.pmp_app_display_name}"
  owners = [
    data.azuread_client_config.current.object_id]
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

resource "azuread_service_principal" "pmp_app_registration" {
  application_id = azuread_application.pmp_app_registration.application_id
  app_role_assignment_required = false
  owners = [
    data.azuread_client_config.current.object_id]
}


resource "azuread_application_password" "pmp_secret" {
  application_object_id = azuread_application.pmp_app_registration.object_id
}
