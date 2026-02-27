package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNetworkModule(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/network/examples/complete",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	networkName := terraform.Output(t, terraformOptions, "network_name")
	assert.NotEmpty(t, networkName)
}
