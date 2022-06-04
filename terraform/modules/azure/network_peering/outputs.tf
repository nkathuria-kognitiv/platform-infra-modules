output "hub_peering_id" {
  description = "Hub peering ID"
  value       = azurerm_virtual_network_peering.hub.id
}

output "remote_peering_id" {
  description = "Remote peering ID"
  value       = azurerm_virtual_network_peering.remote.id
}