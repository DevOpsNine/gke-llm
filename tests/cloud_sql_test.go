package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestCloudSqlModule(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/cloud-sql/examples/complete",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Asserts can be added if output vars are mapped
}
