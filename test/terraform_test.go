package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"

	awsSDK "github.com/aws/aws-sdk-go/aws"
	"github.com/stretchr/testify/assert"
)

func TestTerraform(t *testing.T) {
	t.Parallel()

	expectedClusterName := "skole-jenkins-cluster"
	awsRegion := "us-east-1"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../tf",

		Vars: map[string]interface{}{
			"region": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Look up the ECS cluster by name
	cluster := aws.GetEcsCluster(t, awsRegion, expectedClusterName)
	// Confirm proper amount of services active
	assert.Equal(t, int64(9), awsSDK.Int64Value(cluster.ActiveServicesCount))

	services := map[string]int{
		"gateway":     8080,
		"underwriter": 8081,
		"account":     8082,
		"bank":        8083,
		"transaction": 8085,
		"user":        8086,
		"landing":     4000,
		"dashboard":   4200,
		"admin":       4001,
	}

	// Check individual services
	for key, _ := range services {
		serviceName := fmt.Sprintf("%s-service", key)
		service := aws.GetEcsService(t, awsRegion, expectedClusterName, serviceName)

		assert.Equal(t, int64(1), awsSDK.Int64Value(service.DesiredCount))
		assert.Equal(t, "FARGATE", awsSDK.StringValue(service.LaunchType))

		taskDefinition := awsSDK.StringValue(service.TaskDefinition)
		task := aws.GetEcsTaskDefinition(t, awsRegion, taskDefinition)

		assert.Equal(t, "512", awsSDK.StringValue(task.Cpu))
		assert.Equal(t, "1024", awsSDK.StringValue(task.Memory))
		assert.Equal(t, "awsvpc", awsSDK.StringValue(task.NetworkMode))
	}
}
