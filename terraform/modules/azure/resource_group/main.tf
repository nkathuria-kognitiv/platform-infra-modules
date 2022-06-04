resource "azurerm_resource_group" "rsg" {
  name     = var.rsg_name
  location = var.rsg_location

  tags = {
    environment = var.rsg_environment_tag
    application = var.rsg_application_tag
    project   = var.rsg_project_tag
    owner     = var.rsg_owner_tag
  }
}