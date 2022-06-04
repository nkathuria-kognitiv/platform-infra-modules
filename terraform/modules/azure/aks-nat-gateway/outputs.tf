####################################
# Output NAT details
####################################
output "id" {
  value = azurerm_nat_gateway.natgateway.id
}
output "public_ip" {
  value = module.natpublicip.address
}
