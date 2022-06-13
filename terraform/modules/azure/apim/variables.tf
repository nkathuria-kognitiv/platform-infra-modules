#variable rsg_name{}

variable apim_name{}

variable apim_sku{}

variable apim_publisher_email{
  default = "platform-service-user@kognitiv.com"
}

variable apim_publisher_name{
  default = "Kognitiv"
}

variable "containername" {
  default = "client-programs"
}

variable "storageaccountname" {
}

variable "keyvaultname" {
}

variable "api_key_name" {
}

variable "resource_group_name" {}

variable "tenant_id" {}
variable "apim_app_display_name" {}

variable "certificate_name" {
  default = "internal-kognitiv-cert"
}

variable "custom_domain_host_name" {
}