package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestGKEClusterModule(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gke-cluster/examples/complete",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
