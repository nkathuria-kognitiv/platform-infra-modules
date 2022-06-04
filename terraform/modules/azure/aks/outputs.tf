output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "private_fqdn" {
  value = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity
}
