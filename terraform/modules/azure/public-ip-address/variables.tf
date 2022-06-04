####################################
# Input Variables for Public Ip
####################################
variable "publicip_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "common_tags" {
  type = map(any)
}
variable "zones" {
  type    = list(string)
  default = null
}