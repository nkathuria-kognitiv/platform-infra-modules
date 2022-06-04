This is a simple module to create a nat-gateway and it's child dependencies that is intended to be part of an AKS cluster. For a general purpose usage of a nat-gateway, use the plain `nat-gateway` template which requires passing in of child dependencies.

Example usage:

```
############################################################
# Create Regional NAT and associate with AKS Subnet
############################################################
module "akssubnetregionalnat" {
  source              = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/aks-nat-gateway"
  name                = "${var.aks_cluster_name}-node-pool-subnet-nat"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  common_tags         = local.common_tags
}
resource "azurerm_subnet_nat_gateway_association" "akssubnetregionalnat_aksnodepoolsubnet_association" {
  subnet_id      = module.aksnodepoolsubnet.subnet_id
  nat_gateway_id = module.akssubnetregionalnat.id
}
```

