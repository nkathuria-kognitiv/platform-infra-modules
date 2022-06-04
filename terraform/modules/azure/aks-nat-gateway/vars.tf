####################################
# Input Variables for NAT Gateway
####################################
variable "nat_gateway_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "zones" {
  type    = list(string)
  default = null
}
variable "common_tags" {
  type = map(any)
}
