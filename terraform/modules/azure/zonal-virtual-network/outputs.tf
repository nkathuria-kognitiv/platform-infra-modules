output "vnet" {
  description = "Details of the newly created Virtual Network"
  value       = azurerm_virtual_network.vnet
}

output "zone1nat" {
  value = module.zone1nat
}

output "zone2nat" {
  value = module.zone2nat
}

output "zone3nat" {
  value = module.zone3nat
}

output "publicsubnetzone1" {
  value = module.publicsubnetzone1
}

output "publicsubnetzone2" {
  value = module.publicsubnetzone2
}

output "publicsubnetzone3" {
  value = module.publicsubnetzone3
}

output "privatesubnetzone1" {
  value = module.privatesubnetzone1
}

output "privatesubnetzone2" {
  value = module.privatesubnetzone2
}

output "privatesubnetzone3" {
  value = module.privatesubnetzone3
}

output "vnet_private_dns_zone" {
  value = azurerm_private_dns_zone.vnet_private_dns
}

output "vnet_private_dns_zone_link" {
  value = azurerm_private_dns_zone_virtual_network_link.vnet_private_dns_link
}
