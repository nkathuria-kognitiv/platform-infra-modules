locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = lower("${local.name_prefix}-${var.client_name}-${var.location_short}-${var.environment}")

  pg_server_name = coalesce(var.custom_server_name, "${local.default_name}-psql")

  replica_location = coalesce(var.replica_location, var.location)
}

# PostgreSQL server
resource "azurerm_postgresql_server" "server" {
  administrator_login               = var.db_admin
  administrator_login_password      = var.db_pwd
  auto_grow_enabled                 = var.db_auto_grow_enabled
  backup_retention_days             = var.db_backup_retention_days
  create_mode                       = "Default"
  geo_redundant_backup_enabled      = var.db_geo_redundant_backup
  infrastructure_encryption_enabled = false  # experimental feature, keep set to false
  location                          = var.location
  name                              = local.pg_server_name
  public_network_access_enabled     = var.public_network_access
  resource_group_name               = var.resource_group_name
  sku_name                          = var.db_sku_name
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
  storage_mb                        = var.db_storage_mb
  version                           = "11"

  tags = merge(
    var.tags,
    {
      "environment" = var.environment,
      "capability"  = var.client_name,
      "Terraform"   = "true"
    }
  )
}

# PostgreSQL remote DR replica
resource "azurerm_postgresql_server" "replica" {
  count = var.create_remote_replica ? 1 : 0

  creation_source_server_id         = azurerm_postgresql_server.server.id

  auto_grow_enabled                 = var.db_auto_grow_enabled
  backup_retention_days             = var.db_backup_retention_days
  create_mode                       = "Replica"
  geo_redundant_backup_enabled      = var.db_geo_redundant_backup
  infrastructure_encryption_enabled = false  # experimental feature, keep set to false
  location                          = local.replica_location
  name                              = "${local.pg_server_name}-replica"
  public_network_access_enabled     = var.public_network_access
  resource_group_name               = var.resource_group_name
  sku_name                          = var.db_sku_name
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
  storage_mb                        = var.db_storage_mb
  version                           = "11"

  tags = merge(
    var.tags,
    {
      "environment" = var.environment,
      "capability"  = var.client_name,
      "Terraform"   = "true"
    }
  )
}

# FW Rules
resource "azurerm_postgresql_firewall_rule" "server_fw_rule" {
  for_each = var.fw_allowed_ips

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.server.name
  start_ip_address    = each.value
  end_ip_address      = each.value
}

resource "azurerm_postgresql_virtual_network_rule" "server_vnet_rule" {
  for_each = var.fw_allowed_vnets

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.server.name
  subnet_id           = each.value
}