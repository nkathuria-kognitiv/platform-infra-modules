# - Get the current user config
data "azurerm_client_config" "current" {}

locals {

  common_tags = merge(
    var.global_common_tags,
    var.subscription_common_tags,
    var.environment_common_tags,
    var.role_common_tags,
    var.version_common_tags
  )
}
resource "azurerm_nat_gateway" "this" {
  for_each            = var.nat_gateways
  name                = each.value["name"]
  location            = each.value["location"]
  resource_group_name = each.value["resource_group_name"]
  sku_name            = each.value["sku_name"]
  tags                = merge(each.value["tags"], local.common_tags)

}

locals {
  nat_ip_associates = flatten([
    for nat_key, nat in var.nat_gateways : [
      for ip_key in toset(nat.public_ip_address_names) : {
        nat_key = nat_key
        ip_key  = ip_key

        nat_gateway_id       = azurerm_nat_gateway.this[nat_key].id
        public_ip_address_id = lookup(var.map_pip_ids, ip_key)
      }
    ]
  ])

  nat_ip_prefix_associates = flatten([
    for nat_key, nat in var.nat_gateways : [
      for ipprefix_key in toset(nat.public_ip_prefixe_names) : {
        nat_key      = nat_key
        ipprefix_key = ipprefix_key

        nat_gateway_id      = azurerm_nat_gateway.this[nat_key].id
        public_ip_prefix_id = lookup(var.map_prefix_ids, ipprefix_key)
      }
    ]
  ])

  nat_subnet_associates = flatten([
    for nat_key, nat in var.nat_gateways : [
      for subnet_key in toset(nat.subnet_names) : {
        nat_key    = nat_key
        subnet_key = subnet_key

        nat_gateway_id = azurerm_nat_gateway.this[nat_key].id
        subnet_id      = lookup(var.map_subnet_ids, subnet_key)
      }
    ]
  ])

}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  depends_on = [azurerm_nat_gateway.this]

  for_each = {
    for associate in local.nat_ip_associates : "${associate.nat_key}.${associate.ip_key}" => associate
  }

  nat_gateway_id       = each.value.nat_gateway_id
  public_ip_address_id = each.value.public_ip_address_id
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  depends_on = [azurerm_nat_gateway.this]

  for_each = {
    for associate in local.nat_ip_prefix_associates : "${associate.nat_key}.${associate.ipprefix_key}" => associate
  }

  nat_gateway_id      = each.value.nat_gateway_id
  public_ip_prefix_id = each.value.public_ip_prefix_id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  depends_on = [azurerm_nat_gateway.this]

  for_each = {
    for associate in local.nat_subnet_associates : "${associate.nat_key}.${associate.subnet_key}" => associate
  }

  nat_gateway_id = each.value.nat_gateway_id
  subnet_id      = each.value.subnet_id
}