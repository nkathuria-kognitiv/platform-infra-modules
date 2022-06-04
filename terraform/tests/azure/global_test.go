package tests

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

//Stub variables 
var SubscriptionId = "f2f84b24-dd4b-46f9-a6b7-e81a7fb6c54a" 
var SubscriptionName = "ccp-non-prod"
var TennantId = "5bbed656-4f0a-43a0-bef8-c91aecbe75a3"  
var Location = "eastus"
var ResourceGroupName = "terraform-test-rg" 
var EnvironmentName = "terraform-test-env" 
var TestOwnerTag = "terraform-test" 
var ServiceProfile = "tftest"
var AcrName = "kpscontainerreg"   //UPDATE ME
var AcrResourceGroupName = "kps-dev-rg" //UPDATE ME
var TestKeyVaultName = "terraform-tests-keyvault" 

//template paths
var VnetTerraformLocation = "../../modules/azure/zonal-virtual-network" 
var AksTerraformLocation = "../../modules/azure/aks" 
var BastionTestLocation = "../../modules/azure/bastion-host" 
var publicIp []string


func getBackendConfig(testName string, blobKey string) map[string]interface{} {
	backendConf := map[string]interface{}{
		"resource_group_name":  ResourceGroupName,
		"storage_account_name": "terraformtestsbackend",
		"container_name":       "terratest-tfstate",
		"key":                  blobKey + "/" + testName + "/terraform.tfstate",
	}
	return backendConf
}

func getGlobalCommonTags() map[string]interface{} {
	globalCommonTags := map[string]interface{}{
		"global_tag": "test",
	}
	return globalCommonTags
}

func getSubscriptionCommonTags() map[string]interface{} {
	subscriptionCommonTags := map[string]interface{}{
		"subscription_name": SubscriptionName,
		"owner":             TestOwnerTag,
	}
	return subscriptionCommonTags
}

func getResourceCommonTags() map[string]interface{} {
	resourceCommonTags := map[string]interface{}{
		"resource_group_name": ResourceGroupName,
	}
	return resourceCommonTags
}

func getEnvCommonTags() map[string]interface{} {
	envCommonTags := map[string]interface{}{
		"environment_name": EnvironmentName,
	}
	return envCommonTags
}

func getRoleCommonTags(roleName string) map[string]interface{} {
	roleCommonTags := map[string]interface{}{
		"service_profile": ServiceProfile,
		"role_name":       roleName,
	}
	return roleCommonTags
}

func getTerraformTestOptions(testName string, testLocation string, terraformInputVars map[string]interface{}) *terraform.Options {
	terraformInputVars["release_version"] = "0.00"
	terraformInputVars["global_common_tags"] = getGlobalCommonTags()
	terraformInputVars["subscription_common_tags"] = getSubscriptionCommonTags()
	terraformInputVars["resource_group_common_tags"] = getResourceCommonTags()
	terraformInputVars["environment_common_tags"] = getEnvCommonTags()
	terraformInputVars["role_common_tags"] = getRoleCommonTags(testName)

	blobKey := strings.Replace(testLocation, "../", "", -1)
	blobKey = strings.Replace(blobKey, "..", "", -1)
	blobKey = strings.Replace(blobKey, "//", "/", -1)
	backendConfig := getBackendConfig(testName, blobKey)

	terraformOptions := terraform.Options{
		TerraformDir:  testLocation,
		Vars:          terraformInputVars,
		BackendConfig: backendConfig,
	}
	return &terraformOptions
}

func retry(attempts int, sleep time.Duration, f func() error) (err error) {
	for attempetedCount := 1; ; attempetedCount++ {
		err = f()
		if err == nil {
			return
		}
		if attempetedCount >= (attempts - 1) {
			break
		}
		log.Println("Test ran into error, waiting for " + sleep.String() + " before retry.")
		time.Sleep(sleep)
		log.Println(fmt.Sprint("Retry count: ", attempetedCount))
	}
	return fmt.Errorf("after %d attempts, last error: %s", attempts, err)
}

func terraformDestroyWithRetry(retryCount int, t *testing.T, terraformOptions *terraform.Options) {
	var out string
	err := retry(retryCount, 10*time.Second, func() (err error) {
		log.Print("Destroying test resources.")
		out, err = terraform.DestroyE(t, terraformOptions)
		return
	})
	log.Print(out)
	optionsAsString, err := json.Marshal(terraformOptions)
	if err != nil {
		log.Println("Failed to destroy some of the test resources. Please destroy the resources manually. Terraform Options"+string(optionsAsString), err)
		return
	}
	log.Print("Successfully destroyed resources for terraform options: " + string(optionsAsString))
}

func verifyServiceHealth(t *testing.T, serviceHealthCheckUrl string) {
	out, err := exec.Command("curl", serviceHealthCheckUrl).Output()
	if err != nil {
		println("Error! Service endpoint not healthy " + serviceHealthCheckUrl)
		println(err)
		t.Fail()
	}
	fmt.Printf("Response: %s\n", out)
}

func getMyPublicIp() string {
	url := "https://api.ipify.org?format=text" // we are using a pulib IP API, we're using ipify here, below are some other options
	// https://www.ipify.org
	// http://myexternalip.com
	// http://api.ident.me
	// http://whatismyipaddress.com/api

	fmt.Println("Getting IP address from  ipify ...")
	resp, err := http.Get(url)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()
	ip, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	myPublicIp := string(ip)
	println("Got public IP: " + myPublicIp)
	publicIp = []string{myPublicIp + "/32"}
	return myPublicIp
}
