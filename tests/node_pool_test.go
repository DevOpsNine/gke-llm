package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestNodePoolModule(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/node-pool/examples/complete",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
