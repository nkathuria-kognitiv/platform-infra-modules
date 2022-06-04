This template is for creating a nat-gateway resource and is intended to be have the public IP(s) & subnet(s) passed into it.

Example Terragrunt usage:

```
# Includes all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("common.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  nat_gateways = {
    nat01 = {
      name                = "kls-cc-stage-01"
      resource_group_name = "kls-cc-stage"
      location            = "canadacentral"
      sku_name            = "Standard"

      public_ip_address_names = ["kls-cc-stage-nat"]
      public_ip_prefixe_names = ["kls-cc-stage-natprefix"]
      subnet_names = ["kls-cc-stage-web",
        "kls-cc-stage-db",
        "kls-cc-stage-share"
      ]
      tags = null
    }
  }

  map_pip_ids = dependency.pip.outputs.map_pip_ids

  map_prefix_ids = dependency.pip.outputs.map_prefix_ids

  map_subnet_ids = dependency.landing.outputs.map_subnet_ids
  ```