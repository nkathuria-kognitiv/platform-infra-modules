####################################
# Inputs for VM
####################################
variable "vm_name" {
  type = string
}
variable "vm_subnet_id" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "vm_size" {
  type = string
}
variable "public_ip_address_id" {
  type    = string
  default = null
}
variable "storage_account_name" {
  type    = string
  default = "ccpterraformbackend"
}
variable "storage_account_resource_group_name" {
  type    = string
  default = "ccp-non-prod-rg"
}
variable "bootstrap_script_path" {
  type    = string
  default = "/non-existent"
}
variable "source_image_publisher" {
  type    = string
  default = "Canonical"
}
variable "source_image_offer" {
  type    = string
  default = "UbuntuServer"
}
variable "source_image_sku" {
  type    = string
  default = "18.04-LTS"
}
variable "source_image_version" {
  type    = string
  default = "latest"
}
variable "create_new_ssh_login_key" {
  type    = bool
  default = true
}
variable "ssh_key" {
  type    = string
  default = null
}
variable "private_key_name" {
  type    = string
  default = null
}
variable "key_vault_name" {
  type = string
}
variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "common_tags" {
  type = map(any)
}