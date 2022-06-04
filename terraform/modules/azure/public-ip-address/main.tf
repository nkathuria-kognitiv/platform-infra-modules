####################################
# Create Public Ip
####################################
resource "azurerm_public_ip" "publicip" {
  name                = var.publicip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = var.zones
  tags                = var.common_tags
}
