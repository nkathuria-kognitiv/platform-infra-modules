## generate-ssh-key


This module is intended to be used to create and save an SSH key as part of a resource creation

Example usage, this snippet is expected in the parent template:

```
# Generate and save SSH private key to keyvault
module "ssh_key" {
  source = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/generate-sshkey?ref=0.13"

  resource_group_name = var.resource_group_name
  environment_name    = "${var.common_tags.environment_name}-${var.common_tags.role_name}"
  key_vault_name      = var.key_vault_name
  private_key_name    = var.private_key_name

  common_tags = merge(
    var.common_tags,
    {
      release_version = "0.13"
    }
  )
}
```

This module & it's values can be refereced in any resource declaration. Below is a Linux VM example of using the generated key:


```
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
```