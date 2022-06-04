####################################
# Output for Subnet
####################################
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
output "subnet_address_prefix" {
  value = azurerm_subnet.subnet.address_prefix
}
output "subnet_name" {
  value = azurerm_subnet.subnet.name
}
output "subnet_nsg_id" {
  value = azurerm_network_security_group.nsg.id
}
output "subnet_nsg_name" {
  value = azurerm_network_security_group.nsg.name
}
