#########################################
# List of Default Variables
#########################################
variable "version_common_tags" {
  type = map(any)
}
variable "global_common_tags" {
  type = map(any)
}
variable "subscription_common_tags" {
  type = map(any)
}

variable "environment_common_tags" {
  type = map(any)
}
variable "role_common_tags" {
  type = map(any)
}

####################################
# Inputs for nat gateway
####################################
variable "nat_gateways" {
  description = "The nat gateways with its properties."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku_name            = string

    public_ip_address_names = list(string)
    public_ip_prefixe_names = list(string)
    subnet_names            = list(string)
    tags                    = map(string)
  }))
}

variable "map_pip_ids" {
  type        = map(string)
  description = "Map of Public IP Addresses Id's"
}

variable "map_prefix_ids" {
  type        = map(string)
  description = "Map of Public IP Prefixes Id's"
}

variable "map_subnet_ids" {
  type        = map(string)
  description = "Map of Subnet Id's"
}