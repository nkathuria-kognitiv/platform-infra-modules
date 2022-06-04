####################################
# Output Public Ip details
####################################
output "address" {
  value = azurerm_public_ip.publicip.ip_address
}
output "id" {
  value = azurerm_public_ip.publicip.id
}
