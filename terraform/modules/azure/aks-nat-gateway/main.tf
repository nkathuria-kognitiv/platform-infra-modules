####################################
# Create Public Ip
####################################
# if the ref version is changed the release_version tag needs to be changed as well.
module "natpublicip" {
  source = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/public-ip-address"

  publicip_name       = "${var.nat_gateway_name}-publicip"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  common_tags         = var.common_tags
}

####################################
# Create NAT Gateway
####################################
resource "azurerm_nat_gateway" "natgateway" {
  name                    = var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  zones                   = var.zones
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  tags                    = var.common_tags
}

####################################
# Associate public ip to NAT Gateway
####################################
resource "azurerm_nat_gateway_public_ip_association" "nat_publicip" {
  nat_gateway_id       = azurerm_nat_gateway.natgateway.id
  public_ip_address_id = module.natpublicip.id
}
