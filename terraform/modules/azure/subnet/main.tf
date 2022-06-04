locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = lower("${local.name_prefix}-${var.client_name}-${var.location_short}-${var.environment}")

  subnet_name = coalesce(var.custom_subnet_name, "${local.default_name}-subnet")

  network_security_group_rg = coalesce(var.network_security_group_rg, var.resource_group_name)
  route_table_rg            = coalesce(var.route_table_rg, var.resource_group_name)

  network_security_group_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkSecurityGroups/%s", data.azurerm_subscription.current.subscription_id, local.network_security_group_rg, coalesce(var.network_security_group_name, "fake"))

  route_table_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/routeTables/%s", data.azurerm_subscription.current.subscription_id, local.route_table_rg, coalesce(var.route_table_name, "fake"))
}

resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_cidr_list

  service_endpoints = var.service_endpoints

  dynamic "delegation" {
    for_each = var.subnet_delegation
    content {
      name = delegation.key
      dynamic "service_delegation" {
        for_each = toset(delegation.value)
        content {
          name    = service_delegation.value.name
          actions = service_delegation.value.actions
        }
      }
    }
  }

  enforce_private_link_endpoint_network_policies = var.enforce_private_link
}

resource "azurerm_subnet_network_security_group_association" "subnet_association" {
  count = var.network_security_group_name == null ? 0 : 1

  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = local.network_security_group_id
}

resource "azurerm_subnet_route_table_association" "route_table_association" {
  count = var.route_table_name == null ? 0 : 1

  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = local.route_table_id
}

data "azurerm_subscription" "current" {
}