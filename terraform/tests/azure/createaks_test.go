package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

var aksTestName = "aks"
var aksName = "terratest-aks"
var expectedAksName = aksTestName + "-" + aksName
var expectedAksVnetName = aksTestName + "-" + vnetName

func createAksTestVars(testName string) map[string]interface{} {

	//Set variables to pass to test the terraform code. This map will be set as -var options for terraform
	vars := map[string]interface{}{
		"aks_cluster_name":          testName + "-" + aksName,
		"vnet_name":                 testName + "-" + vnetName,
		"resource_group_name":       ResourceGroupName,
		"system_pool_node_count":    1,
		"user_pool_node_count":      1,
		"subscription_id":           SubscriptionId,
		"aks_node_pool_subnet_cidr": "10.251.0.0/17",
		"aks_cluster_acr_name":      AcrName,
		"acr_resource_group_name":   AcrResourceGroupName,
	}
	return vars
}

func getAksTerraformTestOptions(testName string) *terraform.Options {
	// Get input vars for terraform script
	terraformVars := createVnetVars(aksTestName)
	// Populate terraform options for the provided location of terraform script and input vars
	terraformOptions := getTerraformTestOptions(vnetTestName, VnetTerraformLocation, terraformVars)
	return terraformOptions
}

// Run the test
func TestAZureAKSLaunch(t *testing.T) {
	t.Parallel()

	// Get vnet vars
	creatVnetTfOptions := getVnetTerraformTestOptions(aksTestName)

	// Make sure we run `terraform destroy`, at the end of the test.
	// The order of multiple defer is first in last out hence we defer vnet destory first
	retryCount := 3
	defer terraformDestroyWithRetry(retryCount, t, creatVnetTfOptions)

	// Create Vnet for AKS
	terraform.InitAndApply(t, creatVnetTfOptions)

	// Validate Vnet for AKS
	validateVnetCreationOutput(expectedAksVnetName, t, creatVnetTfOptions)

	// Get aks creation terraform vars and options
	createAksTfOptions := getAksTestTerraformOptions(aksTestName)

	retryCount = 3
	defer terraformDestroyWithRetry(retryCount, t, createAksTfOptions)

	// Create AKS
	terraform.InitAndApply(t, createAksTfOptions)

	// Validate vnet created successfuly
	validateCreatedAKS(expectedAksName, t, createAksTfOptions)
}

func getAksTestTerraformOptions(testName string) *terraform.Options {
	// Get input vars for terraform script
	terraformVars := createAksTestVars(testName)

	// Populate terraform options for the provided location of terraform script and input vars
	createAksTerraformOptions := getTerraformTestOptions(testName, AksTerraformLocation, terraformVars)

	return createAksTerraformOptions
}

func validateCreatedAKS(expectedName string, t *testing.T, terraformOptions *terraform.Options) {
	// Validate AKS Id
	expectedAksId := "/subscriptions/" + SubscriptionId + "/resourcegroups/" + ResourceGroupName + "/providers/Microsoft.ContainerService/managedClusters/" + expectedName
	actualId := terraform.Output(t, terraformOptions, "id")
	require.Equal(t, expectedAksId, actualId)

	// Validate AKS fqdn is empty for private cluster
	expectedFqdn := ""
	actualFqdn := terraform.Output(t, terraformOptions, "fqdn")
	require.Equal(t, expectedFqdn, actualFqdn)

	// Validate AKS node resource group is created as expected
	expectedNodeResourceGroup := "MC_" + ResourceGroupName + "_" + expectedName + "_" + Location
	actualNodeResourceGroup := terraform.Output(t, terraformOptions, "node_resource_group")
	require.Equal(t, expectedNodeResourceGroup, actualNodeResourceGroup)

	// Validate user assigned managed identity for AKS cluster is created and assigned properly
	expectedUserAssignedIdentityId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + expectedNodeResourceGroup + "/providers/Microsoft.ManagedIdentity/userAssignedIdentities/" + expectedName + "-agentpool"
	kubelet_identity := terraform.OutputListOfObjects(t, terraformOptions, "kubelet_identity")
	user_assigned_identity_id := kubelet_identity[0]["user_assigned_identity_id"]
	require.Equal(t, expectedUserAssignedIdentityId, user_assigned_identity_id)
}
