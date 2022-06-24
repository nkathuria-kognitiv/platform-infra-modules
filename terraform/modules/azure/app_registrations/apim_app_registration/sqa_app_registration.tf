
resource "azuread_application" "sqa_app_registration" {
  depends_on = [
    "azuread_application.apim_app_registration"]
  display_name = "${var.sqa_app_display_name}"
  owners = [
    data.azuread_client_config.current.object_id]
  required_resource_access {
    resource_app_id = azuread_application.apim_app_registration.application_id
    resource_access {
      id = "ae299053-cb8a-4805-9f81-362e1024222f"
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "sqa_app_registration" {
  application_id = azuread_application.sqa_app_registration.application_id
  app_role_assignment_required = false
  owners = [
    data.azuread_client_config.current.object_id]
}


resource "azuread_application_password" "sqa_secret" {
  application_object_id = azuread_application.sqa_app_registration.object_id
}
