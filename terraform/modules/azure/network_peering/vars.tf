variable "cluster_name" {
  description = "Name of the DC/OS cluster"
}

variable "hub_region_network" {
  description = "hub region network name, for naming the VNET peering resource"
  type        = string
}

variable "hub_resource_group_name" {
  description = "hub resource group name"
  type        = string
}

variable "hub_vnet_name" {
  description = "hub VNET name"
  type        = string
}

variable "hub_vnet_id" {
  description = "hub VNET ID"
  type        = string
}

variable "remote_region_network" {
  description = "Remote region network name, for naming the VNET peering resource"
  type        = string
}

variable "remote_resource_group_name" {
  description = "Remote resource group name"
  type        = string
}

variable "remote_vnet_name" {
  description = "Remote VNET name"
  type        = string
}

variable "remote_vnet_id" {
  description = "Remote VNET ID"
  type        = string
}
