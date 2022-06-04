package tests

import (
	"flag"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

var serviceTestLocation = "../../azure/"
var serviceTestName = "service-test"
var expectedServiceAksName = serviceTestName + "-" + aksName
var expectedServiceVnetName = serviceTestName + "-" + vnetName

var runTest string
var launchVnetAndAks bool
var skipVnetAksDelete bool
var skipDelete bool
var skipBastionDelete bool
var runVnetApply bool
var runAksApply bool
var runBastionApply bool

func init() {
	flag.StringVar(&runTest, "test-name", "", "Only perform specific tests")
	flag.BoolVar(&launchVnetAndAks, "launch-vnet-aks", true, "launch vnet and aks along with the test")
	flag.BoolVar(&skipVnetAksDelete, "skip-vnet-aks-delete", false, "Skip deletion of vnet and aks when running the test")
	flag.BoolVar(&skipDelete, "skip-delete", false, "Skip deletion of services when running the test")
	flag.BoolVar(&skipBastionDelete, "skip-bastion-delete", false, "Skip deletion of services when running the test")
	flag.BoolVar(&runVnetApply, "vnet-apply", true, "Choose wether to run apply of vnet when running the test")
	flag.BoolVar(&runBastionApply, "bastion-apply", true, "Choose wether to run apply of bastion server when running the test")
	flag.BoolVar(&runAksApply, "aks-apply", true, "Choose wether to run apply of aks when running the test")
	publicIp = []string{getMyPublicIp() + "/32"}

}

// If a new service is added we need to add the test here as well as in the individual test section
func runAllTests(t *testing.T) {
	memberServiceTest(t)
}

// Run the tests
func TestServiceLaunch(t *testing.T) {
	flag.Parse()
	t.Parallel()

	if launchVnetAndAks {
		// Get vnet vars
		creatVnetTfOptions := getVnetTerraformTestOptions(serviceTestName)
		createVnetBastionTfOptions := getTestVnetBastionCreateTerraformOptions(serviceTestName)

		// Make sure we run `terraform destroy`, at the end of the test.
		// The order of multiple defer is first in last out hence we defer vnet destory first
		retryCount := 3
		if !(skipVnetAksDelete) {
			defer terraformDestroyWithRetry(retryCount, t, creatVnetTfOptions)
		}
		if runVnetApply {
			// Create Vnet
			println("Running vnet init apply")
			terraform.InitAndApply(t, creatVnetTfOptions)
			// Validate Vnet
			validateVnetCreationOutput(expectedServiceVnetName, t, creatVnetTfOptions)
		}

		retryCount = 1
		if !(skipBastionDelete) {
			defer terraformDestroyWithRetry(retryCount, t, createVnetBastionTfOptions)
		}
		if runBastionApply {
			// Create Vnet Bastion
			println("Running vnet init apply")
			fmt.Println(createVnetBastionTfOptions)
			terraform.InitAndApply(t, createVnetBastionTfOptions)
		}

		// Get aks creation terraform vars and options
		createAksTfOptions := getAksTestTerraformOptions(serviceTestName)
		if !(skipVnetAksDelete) {
			retryCount = 5
			defer terraformDestroyWithRetry(retryCount, t, createAksTfOptions)
		}
		if runAksApply {
			// Create AKS
			println("Running aks init apply")
			terraform.InitAndApply(t, createAksTfOptions)
			// Validate vnet created successfuly
			validateCreatedAKS(expectedServiceAksName, t, createAksTfOptions)
		}
	}

	//Run service sepecific tests
	if runTest == "member-service" {
		memberServiceTest(t)
	} else if runTest == "" {
		runAllTests(t)
	} else {
		println("Error: Argument not recognized for test-name: " + runTest)
		t.Fail()
	}
}

func memberServiceTest(t *testing.T) {
	var serviceName = "member-service"
	var memberServiceTfLocationn = serviceTestLocation + serviceName

	//Set variables to pass to test the terraform code. This map will be set as -var options for terraform
	memberServiceTfVars := map[string]interface{}{
		"aks_cluster_name":                     expectedServiceAksName,
		"vnet_name":                            expectedServiceVnetName,
		"resource_group_name":                  ResourceGroupName,
		"key_vault_name":                       TestKeyVaultName,
		"server_size_sku_name":                 "GP_Gen5_2",
		"initial_storage_mb":                   51200, // 50 GB
		"public_network_access_enabled":        false,
		"geo_redundant_backup_enabled":         false,
		"database_name":                        "member",
		"backup_retention_days":                7,
		"member_service_k8s_manifest_location": "../../../../klp-member/manifests/" + ServiceProfile,
		"https_access_address_list":            publicIp,
	}

	memberServiceTfOptions := getTerraformTestOptions(serviceName, memberServiceTfLocationn, memberServiceTfVars)

	if !(skipDelete) {
		retryCount := 3
		defer terraformDestroyWithRetry(retryCount, t, memberServiceTfOptions)
	}

	terraform.InitAndApply(t, memberServiceTfOptions)

	//Verify Outputs
	dbId := terraform.Output(t, memberServiceTfOptions, "db_id")
	expectedDbId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.DBforPostgreSQL/servers/" + ServiceProfile + "-" + serviceName + "-" + ResourceGroupName
	require.Equal(t, expectedDbId, dbId)

	dbUrl := terraform.Output(t, memberServiceTfOptions, "db_private_endpoint_url")
	expectedDbUrl := ServiceProfile + "-" + serviceName + "-db." + expectedServiceVnetName + ".privatelink.internal-kognitiv.com"
	require.Equal(t, expectedDbUrl, dbUrl)

	dbPublicAccessDisabled := terraform.Output(t, memberServiceTfOptions, "db_public_access_enabled")
	require.Equal(t, "false", dbPublicAccessDisabled)

	dbSSLEnabled := terraform.Output(t, memberServiceTfOptions, "db_ssl_enforcement_enabled")
	require.Equal(t, "true", dbSSLEnabled)

	dbSSLMinVersion := terraform.Output(t, memberServiceTfOptions, "db_ssl_minimal_tls_version_enforced")
	require.Equal(t, "TLS1_2", dbSSLMinVersion)

	dbPrivatEndpointId := terraform.Output(t, memberServiceTfOptions, "db_vnet_private_endpoint_id")
	expectedDbPrivatEndpointId := "/subscriptions/" + SubscriptionId + "/resourceGroups/" + ResourceGroupName + "/providers/Microsoft.Network/privateEndpoints/" + ServiceProfile + "-" + serviceName + "-" + ResourceGroupName + "-aks-node-pool-pe"
	require.Equal(t, expectedDbPrivatEndpointId, dbPrivatEndpointId)

	memberServiceUrl := terraform.Output(t, memberServiceTfOptions, "member_service_url")
	expectedMemberServiceUrl := "https://" + ServiceProfile + "-" + serviceName + ".internal-kognitiv.com"
	require.Equal(t, expectedMemberServiceUrl, memberServiceUrl)

	// verify application is accessible
	healthCheckUrl := expectedMemberServiceUrl + "/actuator/health"
	verifyServiceHealth(t, healthCheckUrl)
}
