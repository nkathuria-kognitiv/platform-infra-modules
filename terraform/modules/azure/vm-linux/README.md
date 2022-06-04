This module is a composite vm creation module that can utilize the `generate-sshkey` to create a a new SSH keypair(`create_new_ssh_login_key`) or fetch an existing key from a keyvault(`private_key_name`) help setup a Linux VM. It includes creation of the `azurerm_network_security_group`, the `azurerm_network_interface` as part of it's defintion.

The default image type for this is `ubuntu` and specifically currently `18.04-LTS`


Example usage to create a bastion linux VM:

```module "vnet_bastion_vm" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/vm"
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

  common_tags = merge(
    local.common_tags,
    {
      release_version = "0.14"
    }
  )
}
```


This template also supports a bootstrap script via the Azure that you can run on post provisioning to install some baseline tools. The path to the script can be passed in as the  input variable `bootstrap_path`.