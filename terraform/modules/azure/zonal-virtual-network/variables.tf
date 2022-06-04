#########################################
# List of Default Variables
#########################################
variable "release_version" {
  type = string
}
variable "subscription_id" {
  type = string
}
variable "global_common_tags" {
  type = map(any)
}
variable "subscription_common_tags" {
  type = map(any)
}
variable "resource_group_common_tags" {
  type = map(any)
}
variable "environment_common_tags" {
  type = map(any)
}
variable "role_common_tags" {
  type = map(any)
}

#########################################
# Module Variables
#########################################

variable "vnet_name" {
  type    = string
  default = null
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type    = string
  default = "10.1.0.0/16"
}

variable "privatesubnetaddress1" {
  type    = string
  default = "10.1.201.0/24"
}

variable "privatesubnetaddress2" {
  type    = string
  default = "10.1.202.0/24"
}

variable "privatesubnetaddress3" {
  type    = string
  default = "10.1.203.0/24"
}

variable "publicsubnetaddress1" {
  type    = string
  default = "10.1.240.0/24"
}

variable "publicsubnetaddress2" {
  type    = string
  default = "10.1.241.0/24"
}

variable "publicsubnetaddress3" {
  type    = string
  default = "10.1.242.0/24"
}
variable "launch_vnet_bastion_server" {
  type    = bool
  default = true
}
variable "privatelinksubnetaddress" {
  type    = string
  default = "10.1.250.0/24"
}
variable "private_link_domain" {
  type    = string
  default = "privatelink.internal-kognitiv.com"
}
variable "create_zonal_subnets" {
  type    = bool
  default = true
}
