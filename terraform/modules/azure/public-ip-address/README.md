This is a very simple template to acquire a public ip address from azure.

Example usage:

```
module "natpublicip" {
  source = "git@github.com:Demeure/platform-infrastructure-modules.git//terraform/modules/azure/public-ip-address"

  publicip_name       = "${var.nat_gateway_name}-publicip"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  common_tags         = var.common_tags
}
```