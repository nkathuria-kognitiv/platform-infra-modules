####################################
# Create VM
####################################
# Create Network Security Group and rule
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.vm_name}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.common_tags

}

# Create network interface
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "${var.vm_name}-nic-ip-config"
    subnet_id                     = var.vm_subnet_id
    public_ip_address_id          = var.public_ip_address_id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    primary                       = true
  }
  tags = var.common_tags

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_nic_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Fetch storage account detail for vm boot diagnostics
data "azurerm_storage_account" "vm_boot_diagnostics_storage_account" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}

# Generate and save SSH private key to keyvault
module "ssh_key" {
  source = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/generate-sshkey"

  resource_group_name = var.resource_group_name
  environment_name    = "${var.common_tags.environment_name}-${var.common_tags.role_name}"
  key_vault_name      = var.key_vault_name
  private_key_name    = var.private_key_name

  common_tags = var.common_tags
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = var.source_image_version
  }

  computer_name                   = var.vm_name
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.create_new_ssh_login_key == true ? module.ssh_key.public_key : var.ssh_key
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.vm_boot_diagnostics_storage_account.primary_blob_endpoint
  }

  tags = var.common_tags
}

# Setup bootstrap script
resource "azurerm_virtual_machine_extension" "setupvmextension" {
  name                 = "${var.vm_name}-vmextension"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  count    = fileexists(var.bootstrap_script_path) == true ? 1 : 0
  settings = <<BOOTSTRAP
    {
      "script": "${base64gzip(file(var.bootstrap_script_path))}"
    }
  BOOTSTRAP

  tags = var.common_tags
}
