########################################################################
# Generate private key for RSA pair and save it to keyvault
########################################################################
locals {
  private_key_name = var.private_key_name == null ? "${var.environment_name}-${var.key_username}" : var.private_key_name
}

# Fetch existing resource group details from azure
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}
data "azurerm_key_vault" "keyvault" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}


# Create a new SSH key
resource "tls_private_key" "rsa_2048_key" {
  algorithm = var.algorithm
  rsa_bits = var.rsa_bits
}

resource "azurerm_key_vault_secret" "keyvault_private_key" {
  name         = local.private_key_name
  value        = tls_private_key.rsa_2048_key.private_key_pem
  key_vault_id = data.azurerm_key_vault.keyvault.id
  tags      = var.common_tags
}



