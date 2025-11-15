.PHONY: help init plan apply destroy connect status validate format

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform
	terraform init

plan: ## Plan Terraform changes
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy all infrastructure
	terraform destroy

connect: ## Connect kubectl to the cluster
	@echo "Getting cluster credentials..."
	@gcloud container clusters get-credentials $$(terraform output -raw cluster_name) \
		--region $$(terraform output -raw cluster_region) \
		--project $$(terraform output -raw project_id 2>/dev/null || cat terraform.tfvars | grep project_id | cut -d'=' -f2 | tr -d ' "')

status: ## Check cluster status
	@echo "=== Cluster Info ==="
	@kubectl cluster-info
	@echo "\n=== Nodes ==="
	@kubectl get nodes -o wide
	@echo "\n=== Namespaces ==="
	@kubectl get namespaces
	@echo "\n=== All Pods ==="
	@kubectl get pods -A
	@echo "\n=== Services ==="
	@kubectl get svc -A

istio-status: ## Check Istio Gateway status
	@echo "=== Istio System Pods ==="
	@kubectl get pods -n istio-system
	@echo "\n=== Istio Gateway Service ==="
	@kubectl get svc -n istio-system
	@echo "\n=== Istio Gateway LoadBalancer IP ==="
	@kubectl get svc -n istio-system -l istio=ingressgateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'
	@echo ""

validate: ## Validate Terraform configuration
	terraform validate
	terraform fmt -check

format: ## Format Terraform files
	terraform fmt -recursive

