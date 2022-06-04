#########################################
# List of Default Variables
#########################################
variable "release_version" {
  type = string
}
variable "global_common_tags" {
  type = map(any)
}
variable "subscription_common_tags" {
  type = map(any)
}
variable "resource_group_common_tags" {
  type = map(any)
}
variable "environment_common_tags" {
  type = map(any)
}
variable "role_common_tags" {
  type = map(any)
}
variable "subscription_id" {
  type = string
}

#########################################
# AKS, Network & Subnets
#########################################
variable "aks_cluster_name" {
  type = string
}
variable "aks_cluster_version" {
  type    = string
  default = "1.20.7"
}
variable "vnet_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "aks_cluster_acr_name" {
  type = string
}
variable "acr_resource_group_name" {
  type = string
}
variable "k8s_docker_bridge_cidr" {
  type    = string
  default = "172.17.0.1/16"
}

variable "k8s_service_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "k8s_dns_service_ip" {
  type    = string
  default = "10.0.0.10"
}

variable "aks_node_pool_subnet_cidr" {
  type    = string
  default = "10.1.0.0/17"
}


#########################################################
# Node pool type, node count and max pods per node
#########################################################
variable "system_node_pool_vm_size" {
  type    = string
  default = "Standard_B2s"
}
variable "system_pool_node_count" {
  type    = number
  default = 1

  validation {
    condition     = var.system_pool_node_count <= 3
    error_message = "Saftey check failure! Current max system pool node count is set to 3. If you need to increase the node count increase the max allowed node in aks variables.tf."
  }
}
variable "system_node_pool_max_pods" {
  type    = number
  default = 30

  validation {
    condition     = var.system_node_pool_max_pods < 31
    error_message = "Cannot increase more than 30 pods per system node pool."
  }
}

variable "user_node_pool_vm_size" {
  type    = string
  default = "Standard_B2s"
}
variable "user_pool_node_count" {
  type    = number
  default = 3

  validation {
    condition     = var.user_pool_node_count <= 6
    error_message = "Saftey check failure! Current max user pool node count is set to 6. If you need to increase the node count, increase the max allowed node in aks variables.tf."
  }
}
variable "user_node_pool_max_pods" {
  type    = string
  default = 30

  validation {
    condition     = var.user_node_pool_max_pods < 51
    error_message = "Cannot increase more than 50 pods per user node pool."
  }
}
variable "enable_node_pool_host_encryption" {
  type    = bool
  default = false
}
