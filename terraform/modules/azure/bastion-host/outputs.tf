####################################
# Outputs for VM
####################################
output "bastion_vm" {
  value = module.vnet_bastion_vm
  sensitive = true
}