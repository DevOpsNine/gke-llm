.PHONY: help init plan apply destroy connect status validate format setup-backend migrate-state backend-full backend-status

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup-backend: ## Setup GCS backend for Terraform state (run once)
	@echo "=== Setting up GCS Backend ==="
	@PROJECT_ID=$$(grep '^project_id' terraform.tfvars | cut -d'=' -f2 | tr -d ' "'); \
	REGION=$$(grep '^region' terraform.tfvars | cut -d'=' -f2 | tr -d ' "'); \
	BUCKET_NAME="$$PROJECT_ID-terraform-state"; \
	echo "Project: $$PROJECT_ID"; \
	echo "Region: $$REGION"; \
	echo "Bucket: gs://$$BUCKET_NAME"; \
	if gsutil ls -b gs://$$BUCKET_NAME 2>/dev/null; then \
		echo "✓ Bucket already exists"; \
	else \
		echo "Creating bucket..."; \
		gsutil mb -p $$PROJECT_ID -l $$REGION -b on gs://$$BUCKET_NAME; \
		gsutil versioning set on gs://$$BUCKET_NAME; \
		gsutil uniformbucketlevelaccess set on gs://$$BUCKET_NAME; \
		echo "✓ Bucket created with versioning enabled"; \
	fi
	@echo "\n=== Backend Configuration ==="
	@echo "Bucket is ready. Backend configuration is already in backend.tf"
	@echo "Next step: Run 'make migrate-state' to migrate your state to GCS"

migrate-state: ## Migrate local state to GCS backend
	@echo "=== Migrating State to GCS ==="
	@echo "This will move your local terraform.tfstate to GCS bucket"
	terraform init -migrate-state

backend-full: ## Setup backend and migrate state (one command)
	@$(MAKE) setup-backend
	@echo ""
	@$(MAKE) migrate-state

backend-status: ## Check GCS backend status
	@echo "=== GCS Backend Status ==="
	@PROJECT_ID=$$(grep '^project_id' terraform.tfvars | cut -d'=' -f2 | tr -d ' "'); \
	BUCKET_NAME="$$PROJECT_ID-terraform-state"; \
	echo "Bucket: gs://$$BUCKET_NAME"; \
	if gsutil ls -b gs://$$BUCKET_NAME 2>/dev/null; then \
		echo "✓ Bucket exists"; \
		echo "\nVersioning status:"; \
		gsutil versioning get gs://$$BUCKET_NAME; \
		echo "\nState files:"; \
		gsutil ls -lh gs://$$BUCKET_NAME/terraform/state/ 2>/dev/null || echo "No state files found"; \
		echo "\nState versions (last 5):"; \
		gsutil ls -la gs://$$BUCKET_NAME/terraform/state/default.tfstate 2>/dev/null | head -5 || echo "No versions found"; \
	else \
		echo "✗ Bucket does not exist. Run 'make setup-backend' first."; \
	fi

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

