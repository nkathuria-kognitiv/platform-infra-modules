package tests

import (
	"encoding/json"
	"log"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

var vnetTestName = "vnet"
var vnetName = "terratest-vnet"
var expectedVnetName = vnetTestName + "-" + vnetName
var expectedVnetAddressSpaceCidr = "10.251.0.0/16"

func createVnetVars(testName string) map[string]interface{} {

	//Set variables to pass to test the terraform code. This map will be set as -var options for terraform
	vars := map[string]interface{}{
		"subscription_id":          SubscriptionId,
		"vnet_name":                testName + "-" + vnetName,
		"address_space":            expectedVnetAddressSpaceCidr,
		"resource_group_name":      ResourceGroupName,
		"privatesubnetaddress1":    "10.251.201.0/24",
		"privatesubnetaddress2":    "10.251.202.0/24",
		"privatesubnetaddress3":    "10.251.203.0/24",
		"publicsubnetaddress1":     "10.251.240.0/24",
		"publicsubnetaddress2":     "10.251.241.0/24",
		"publicsubnetaddress3":     "10.251.242.0/24",
		"privatelinksubnetaddress": "10.251.250.0/24",
	}
	return vars
}

// Run the test
func TestAZureMultiAZVpcLaunch(t *testing.T) {
	// t.Parallel()

	terraformOptions := getVnetTerraformTestOptions(vnetTestName)

	//Make sure we run `terraform destroy`, at the end of the test whether test pass or fail to clean up any resources that were just created
	retryCount := 1
	defer terraformDestroyWithRetry(retryCount, t, terraformOptions)

	//This executes `terraform init` and `terraform apply` command and will fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Validate output
	validateVnetCreationOutput(expectedVnetName, t, terraformOptions)
}

func getVnetTerraformTestOptions(testName string) *terraform.Options {
	// Get input vars for terraform script
	terraformVars := createVnetVars(testName)
	// Populate terraform options for the provided location of terraform script and input vars
	terraformOptions := getTerraformTestOptions(testName, VnetTerraformLocation, terraformVars)

	//have to do this to avoid collisions 
	terraformOptions.Parallelism = 1

	return terraformOptions
}

func validateVnetCreationOutput(expectedName string, t *testing.T, terraformOptions *terraform.Options) {

	// Validate VNET
	vnet := terraform.OutputJson(t, terraformOptions, "vnet")
	var vnetObjMap map[string]interface{}
	if err := json.Unmarshal([]byte(vnet), &vnetObjMap); err != nil {
		log.Fatal(err)
	}

	vnetAddressSpace := vnetObjMap["address_space"].([]interface{})[0].(string)
	vnetLocation := vnetObjMap["location"].(string)
	vnet_id := vnetObjMap["id"].(string)

	expectedVnetId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/" + expectedName
	require.Equal(t, expectedVnetAddressSpaceCidr, vnetAddressSpace)
	require.Equal(t, Location, vnetLocation)
	require.Equal(t, expectedVnetId, vnet_id)

	// Validate NAT
	nat := terraform.OutputMap(t, terraformOptions, "zone1nat")
	zone1NatId := nat["id"]
	nat = terraform.OutputMap(t, terraformOptions, "zone2nat")
	zone2NatId := nat["id"]
	nat = terraform.OutputMap(t, terraformOptions, "zone3nat")
	zone3NatId := nat["id"]

	expectedZone1NatId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/natGateways/" + expectedName + "-nat-zone1"
	expectedZone2NatId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/natGateways/" + expectedName + "-nat-zone2"
	expectedZone3NatId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/natGateways/" + expectedName + "-nat-zone3"

	require.Equal(t, expectedZone1NatId, zone1NatId)
	require.Equal(t, expectedZone2NatId, zone2NatId)
	require.Equal(t, expectedZone3NatId, zone3NatId)

	//Validate Private Subnets
	subnet := terraform.OutputMap(t, terraformOptions, "privatesubnetzone1")
	privatesubnetzone1 := subnet["subnet_id"]
	subnet = terraform.OutputMap(t, terraformOptions, "privatesubnetzone2")
	privatesubnetzone2 := subnet["subnet_id"]
	subnet = terraform.OutputMap(t, terraformOptions, "privatesubnetzone3")
	privatesubnetzone3 := subnet["subnet_id"]

	expectedZone1PrivateSubnetId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/" + expectedName + "/subnets/" + "private-zone1-" + expectedName
	expectedZone2PrivateSubnetId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/" + expectedName + "/subnets/" + "private-zone2-" + expectedName
	expectedZone3PrivateSubnetId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/" + expectedName + "/subnets/" + "private-zone3-" + expectedName

	require.Equal(t, expectedZone1PrivateSubnetId, privatesubnetzone1)
	require.Equal(t, expectedZone2PrivateSubnetId, privatesubnetzone2)
	require.Equal(t, expectedZone3PrivateSubnetId, privatesubnetzone3)

	//Validate Public Subnets
	subnet = terraform.OutputMap(t, terraformOptions, "publicsubnetzone1")
	publicsubnetzone1 := subnet["subnet_id"]
	subnet = terraform.OutputMap(t, terraformOptions, "publicsubnetzone2")
	publicsubnetzone2 := subnet["subnet_id"]
	subnet = terraform.OutputMap(t, terraformOptions, "publicsubnetzone3")
	publicsubnetzone3 := subnet["subnet_id"]

	expectedZone1PublicSubnetId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/" + expectedName + "/subnets/" + "public-zone1-" + expectedName
	expectedZone2PublicSubnetId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/" + expectedName + "/subnets/" + "public-zone2-" + expectedName
	expectedZone3PublicSubnetId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/virtualNetworks/" + expectedName + "/subnets/" + "public-zone3-" + expectedName

	require.Equal(t, expectedZone1PublicSubnetId, publicsubnetzone1)
	require.Equal(t, expectedZone2PublicSubnetId, publicsubnetzone2)
	require.Equal(t, expectedZone3PublicSubnetId, publicsubnetzone3)
}

func getTestVnetBastionCreateTerraformOptions(testName string) *terraform.Options {
	// Get input vars for terraform script
	terraformVars := map[string]interface{}{
		"vnet_name":               serviceTestName + "-" + vnetName,
		"subnet_name":             "public-zone1-" + serviceTestName + "-" + vnetName,
		"resource_group_name":     ResourceGroupName,
		"key_vault_name":          TestKeyVaultName,
		"location":                Location,
		"vm_size":                 "Standard_B2s",
		"ssh_source_address_list": publicIp,
		"skip_bootstrap":          false,
	}
	// Populate terraform options for the provided location of terraform script and input vars
	terraformOptions := getTerraformTestOptions(testName, BastionTestLocation, terraformVars)
	return terraformOptions
}
