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

# Get subscription details
data "azurerm_subscription" "subscription" {
  subscription_id = var.subscription_id
}

# Defin common tags for all resources
locals {
  # The tags had to be defined separately since source in the module section does not allow variables.
  # If you are changing this variable, you will need to change them in individual module source section as well.
  subnet_module_release_version_tag     = "0.08"
  natgateway_module_release_version_tag = "0.08"

  vnet_name = var.vnet_name == null ? "${var.environment_common_tags.environment_name}-${var.role_common_tags.role_name}" : var.vnet_name
  common_tags = merge(
    var.global_common_tags,
    var.subscription_common_tags,
    var.resource_group_common_tags,
    var.environment_common_tags,
    var.role_common_tags,
    {
      release_version = var.release_version
    },
    {
      vnet = "${var.environment_common_tags.environment_name}-${var.role_common_tags.role_name}"
    }
  )
}

# Fetch existing resource group details from azure
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}



#############################
# Create VNet
#############################
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  address_space       = [var.address_space]
  tags                = local.common_tags
}



#############################
# Create Public Subnets
#############################
module "publicsubnetzone1" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/zonal-subnet?ref=v0.1.2-alpha"
  subnet_name         = "public-zone1-${azurerm_virtual_network.vnet.name}"
  subnet_address_cidr = var.publicsubnetaddress1
  vnet_name           = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.subnet_module_release_version_tag
    }
  )
}
module "publicsubnetzone2" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/zonal-subnet?ref=v0.1.2-alpha"
  subnet_name         = "public-zone2-${azurerm_virtual_network.vnet.name}"
  subnet_address_cidr = var.publicsubnetaddress2
  vnet_name           = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.subnet_module_release_version_tag
    }
  )
}
module "publicsubnetzone3" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/zonal-subnet?ref=v0.1.2-alpha"
  subnet_name         = "public-zone3-${azurerm_virtual_network.vnet.name}"
  subnet_address_cidr = var.publicsubnetaddress3
  vnet_name           = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.subnet_module_release_version_tag
    }
  )
}



#############################
# Create Private Subnets
#############################
module "privatesubnetzone1" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/zonal-subnet?ref=v0.1.2-alpha"
  subnet_name         = "private-zone1-${azurerm_virtual_network.vnet.name}"
  subnet_address_cidr = var.privatesubnetaddress1
  vnet_name           = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.subnet_module_release_version_tag
    }
  )
}
module "privatesubnetzone2" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/zonal-subnet?ref=v0.1.2-alpha"
  subnet_name         = "private-zone2-${azurerm_virtual_network.vnet.name}"
  subnet_address_cidr = var.privatesubnetaddress2
  vnet_name           = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.subnet_module_release_version_tag
    }
  )
}
module "privatesubnetzone3" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/zonal-subnet?ref=v0.1.2-alpha"
  subnet_name         = "private-zone3-${azurerm_virtual_network.vnet.name}"
  subnet_address_cidr = var.privatesubnetaddress3
  vnet_name           = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.subnet_module_release_version_tag
    }
  )
}



############################################################
# Create zonal NAT and associate with private subnets
############################################################
# Create NAT in Zone 1
module "zone1nat" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/aks-nat-gateway?ref=v0.1.2-alpha"
  nat_gateway_name    = "${azurerm_virtual_network.vnet.name}-nat-zone1"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  zones               = ["1"]
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.natgateway_module_release_version_tag
    }
  )
}
resource "azurerm_subnet_nat_gateway_association" "nat1_privatesubnet1_association" {
  subnet_id      = module.privatesubnetzone1.subnet_id
  nat_gateway_id = module.zone1nat.id
}

# Create NAT in Zone 2
module "zone2nat" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/aks-nat-gateway?ref=v0.1.2-alpha"
  nat_gateway_name    = "${azurerm_virtual_network.vnet.name}-nat-zone2"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  zones               = ["2"]
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.natgateway_module_release_version_tag
    }
  )
}
resource "azurerm_subnet_nat_gateway_association" "nat2_privatesubnet2_association" {
  subnet_id      = module.privatesubnetzone2.subnet_id
  nat_gateway_id = module.zone2nat.id
}

# Create NAT in Zone 3
module "zone3nat" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/aks-nat-gateway?ref=v0.1.2-alpha"
  nat_gateway_name    = "${azurerm_virtual_network.vnet.name}-nat-zone3"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  zones               = ["3"]
  common_tags = merge(
    local.common_tags,
    {
      release_version = local.natgateway_module_release_version_tag
    }
  )
}
resource "azurerm_subnet_nat_gateway_association" "nat3_privatesubnet3_association" {
  subnet_id      = module.privatesubnetzone3.subnet_id
  nat_gateway_id = module.zone3nat.id
}



############################################################
# Setup subnet & private DNS Zone for the VNet
############################################################
module "privatednslinksubnet" {
  source                                         = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/zonal-subnet?ref=v0.1.2-alpha"
  subnet_name                                    = "private-dns-link-${azurerm_virtual_network.vnet.name}"
  subnet_address_cidr                            = var.privatelinksubnetaddress
  vnet_name                                      = azurerm_virtual_network.vnet.name
  resource_group_name                            = data.azurerm_resource_group.resource_group.name
  location                                       = data.azurerm_resource_group.resource_group.location
  service_endpoints                              = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = "true"

  common_tags = merge(
    local.common_tags,
    {
      release_version = local.subnet_module_release_version_tag
    }
  )
}

resource "azurerm_private_dns_zone" "vnet_private_dns" {
  name                = "${azurerm_virtual_network.vnet.name}.${var.private_link_domain}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

# Link the Private DNS Zone with the VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_private_dns_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-private-dns-link"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.vnet_private_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
