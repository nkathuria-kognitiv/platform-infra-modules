output "id" {
  value = [for x in azurerm_nat_gateway.this : x.id]
}

output "map_pip_ids" {
  value = { for x in azurerm_nat_gateway.this : x.name => x.id }
}
