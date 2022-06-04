provider "azurerm" {
  features {}
}

####################################
# Create and associate NSG, Subnet
####################################
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}
resource "azurerm_subnet" "subnet" {
  name                                           = var.subnet_name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = var.vnet_name
  address_prefixes                               = [var.subnet_address_cidr]
  service_endpoints                              = var.service_endpoints
  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies
}
resource "azurerm_subnet_network_security_group_association" "subnetnsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
