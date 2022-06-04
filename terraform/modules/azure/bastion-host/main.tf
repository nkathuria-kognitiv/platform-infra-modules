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

# Define common tags for all resources
locals {
  # Same bootstrap script is not allowed to be executed twice
  bootstrap_script_path = var.skip_bootstrap == true ? "skip_bootstrap_script" : "${path.module}/scripts/bastion-bootstrap.sh"
  admin_username        = "azureuser"
  vm_name               = "${var.vnet_name}-bastion-server"

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
      vnet = var.vnet_name
    }
  )
}

#######################################################
# VNet Bastion Server (Management Server)
#######################################################
# Fetch existing resource group details from azure
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}
# Fetch existing vnet details to verify network exists
data "azurerm_subnet" "bastion_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}

# Create PublicIp for bastion server
module "vm_public_ip" {
  source = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/public-ip-address"
  common_tags         = local.common_tags
  publicip_name       = "${local.vm_name}-publicip"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.resource_group.location
}


module "vnet_bastion_vm" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/vm-linux"
  resource_group_name = var.resource_group_name
  location            = var.location
  vm_subnet_id        = data.azurerm_subnet.bastion_subnet.id

  vm_size               = var.vm_size
  vm_name               = local.vm_name
  public_ip_address_id  = module.vm_public_ip.id
  bootstrap_script_path = local.bootstrap_script_path
  private_key_name      = "${local.vm_name}-${local.admin_username}"
  key_vault_name        = var.key_vault_name
  admin_username        = local.admin_username

  common_tags           = local.common_tags
}

resource "azurerm_network_security_rule" "bastion_vm_nsg_rule" {
  name                        = "port_22_${local.vm_name}_rule"
  priority                    = 999
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = var.ssh_source_address_list
  source_port_range           = "*"
  destination_address_prefix  = module.vnet_bastion_vm.vm.private_ip_address
  destination_port_range      = 22
  resource_group_name         = var.resource_group_name
  network_security_group_name = "${local.vm_name}-nsg"
}

resource "azurerm_network_security_rule" "vm_subnet_nsg_rule" {
  name                        = "port_22_${var.subnet_name}_rule"
  priority                    = 999
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = var.ssh_source_address_list
  source_port_range           = "*"
  destination_address_prefix  = module.vnet_bastion_vm.vm.private_ip_address
  destination_port_range      = 22
  resource_group_name         = var.resource_group_name
  network_security_group_name = "${var.subnet_name}-nsg"
}
