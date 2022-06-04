resource "azurerm_virtual_network_peering" "hub" {
  name                         = "${var.cluster_name}-${var.hub_region_network}-${var.remote_region_network}"
  resource_group_name          = var.hub_resource_group_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = var.remote_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "remote" {
  name                         = "${var.cluster_name}-${var.remote_region_network}-${var.hub_region_network}"
  resource_group_name          = var.remote_resource_group_name
  virtual_network_name         = var.remote_vnet_name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}
