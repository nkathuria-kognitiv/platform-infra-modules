####################################
# Input Variables for subnet
####################################
variable "subnet_name" {
  type = string
}
variable "subnet_address_cidr" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "service_endpoints" {
  type    = list(string)
  default = []
}
variable "enforce_private_link_endpoint_network_policies" {
  type    = bool
  default = false
}
variable "common_tags" {
  type = map(any)
}
