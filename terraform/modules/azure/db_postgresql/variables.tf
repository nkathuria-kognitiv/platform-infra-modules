variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for subnet names"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "custom_server_name" {
  description = "Optional custom server name"
  type        = string
  default     = null
}

variable "db_admin" {
  type        = string
  description = "Database administrator user"
}

variable "db_pwd" {
  type        = string
  description = "Database administrator password"
}

variable "db_storage_mb" {
  type        = number
  description = "Database storage size in MB"
}

variable "db_auto_grow_enabled" {
  description = "Flag to indicate if the server supports storage auto grow"
  type        = bool
  default     = false
}

variable "db_sku_name" {
  type        = string
  description = "Database SKU"
  default     = "GP_Gen5_2"
}

variable "db_backup_retention_days" {
  type        = number
  description = "Database backup retention days"
  default     = 7
}

variable "db_geo_redundant_backup" {
  description = "Flag to indicate if the geo redundant backup is enabled"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "The location in which the resources will be created."
  type        = string
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
}

variable "replica_location" {
  description = "The location in which the replica will be created (DR region)"
  type        = string
}

variable "public_network_access" {
  description = "Flag to indicate if the server can be reachable over public network"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags shared by all resources of this module. Will be merged with any other specific tags by resource."
  default     = {}
}

variable "create_remote_replica" {
  description = "Flag to indicate if the server needs a remote replica as hot backup"
  type        = bool
  default     = false
}

variable "fw_allowed_ips" {
  description = "Map with all the IPs that are allowed via public network access, in key:value format (description:IP)"
  default     = {}
}

variable "fw_allowed_vnets" {
  description = "Map with all the vNet IDs that are allowed to access, in key:value format (description:SubnetID)"
  default     = {}
}