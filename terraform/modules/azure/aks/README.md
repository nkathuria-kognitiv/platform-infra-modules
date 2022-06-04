This template is intended to create an AKS cluster and encompasses all of the underlying components required to build a cluster. This includes the nat-gateway, subnet & public-ip for the nat-gateway. 

This module was originally intended to be hydrated/called from terragrunt and an example configuration is below:

```
# Includes all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("common.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  vnet_name                        = "kps-nonprod-vnet"

  aks_cluster_name                 = "kps-nonprod-aks"
  aks_cluster_version              = "1.20.2"
  aks_cluster_acr_name             = "kpscontainerreg"
  acr_resource_group_name          = "kps-dev-rg"
  aks_node_pool_subnet_cidr        = "10.1.0.0/17"

  k8s_docker_bridge_cidr           = "172.17.0.1/16"
  k8s_service_cidr                 = "10.0.0.0/16"
  k8s_dns_service_ip               = "10.0.0.10"

  system_node_pool_vm_size         = "Standard_B2s"
  system_pool_node_count           = 1
  system_node_pool_max_pods        = 30

  user_node_pool_vm_size           = "Standard_B2s"
  user_pool_node_count             = 3
  user_node_pool_max_pods          = 30

  enable_node_pool_host_encryption = false 
}
```

There also is an expectation that the subscription will be passed from a global variable group as part of this command. In the above example it is included as part of hte `common.hcl` config stack.