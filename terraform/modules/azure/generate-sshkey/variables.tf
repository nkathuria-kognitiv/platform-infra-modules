########################################################################
# Inputs
########################################################################
variable "resource_group_name" {
  type = string
}
variable "environment_name" {
  type = string
}
variable "key_vault_name" {
  type = string
}
variable "private_key_name" {
  type = string
  default = null
}
variable "key_username" {
  type = string
  default = "azureuser"
}
variable "common_tags" {
  type = map(any)
}
variable "algorithm" {
  type = string
  default = "RSA"
}
variable "rsa_bits" {
  type = number
  default = 2048
}