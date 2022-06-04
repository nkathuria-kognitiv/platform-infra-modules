
This module is intended to be used to copy a file to a remote machine and stage it for execution which can be provided as an option(`execute_file = true`)

A common usage of this script will be to copy a deployment instruction set for a service to be deployed to either K8s or a VM.

The expectation is that the service will create a shell script nested in the script folder in it's infra code and copy it to the appropiate location for deployment. For a K8s service the Bastion host is the correct location to copy & execute the deployment script.

Below is an example of the member service using the module to deploy itself to the shared K8s cluster. The flags are part of the boiler plate deployment script that was created to help standardize & shorten the deploy process.

```

# Deploy member service
module "deploy_member_service" {
  wait_handle = null_resource.copy_k8s_deployment_manifest

  source = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/remote-file"

  remote_host   = data.azurerm_public_ip.vnet_bastion_ip.ip_address
  ssh_user      = var.vnet_bastion_user
  private_key   = data.azurerm_key_vault_secret.keyvault_private_key.value
  executor_role = var.role_common_tags.role_name

  file_path    = "scripts/member-service.sh"
  file_args    = "install --environment-name ${local.common_tags.environment_name} --service-profile ${local.common_tags.service_profile} --az-subscription ${local.common_tags.subscription_name} --az-dns-resource-group ${var.service_domain_resource_group} --db-url ${local.db_fqdn} --db-resource-group ${var.resource_group_name} --az-key-vault ${var.key_vault_name}"
  execute_file = true
}

```

This module can also just generically be used to copy files around and execute them. It was primarily used initially as a deployment harness but can be used in any remote execution scenario desired.