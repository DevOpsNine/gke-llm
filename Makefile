.PHONY: help init plan apply destroy connect deploy-llm status clean

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

deploy-llm: ## Deploy LLM to Kubernetes
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/llm-deployment.yaml
	kubectl apply -f k8s/llm-service.yaml
	kubectl apply -f k8s/llm-hpa.yaml
	@echo "\nWaiting for deployment..."
	kubectl wait --for=condition=available --timeout=600s deployment/llm-inference -n llm-inference || true

status: ## Check deployment status
	@echo "=== Nodes ==="
	kubectl get nodes -o wide
	@echo "\n=== GPU Nodes ==="
	kubectl get nodes -l workload=gpu-llm -o wide
	@echo "\n=== Pods ==="
	kubectl get pods -n llm-inference -o wide
	@echo "\n=== Services ==="
	kubectl get svc -n llm-inference
	@echo "\n=== HPA ==="
	kubectl get hpa -n llm-inference

logs: ## Show LLM pod logs
	kubectl logs -f -n llm-inference -l app=llm-inference

gpu-check: ## Check GPU availability on nodes
	@echo "Checking GPU on nodes..."
	@for node in $$(kubectl get nodes -l workload=gpu-llm -o jsonpath='{.items[*].metadata.name}'); do \
		echo "\n=== Node: $$node ==="; \
		kubectl describe node $$node | grep -A 10 "Allocatable:" | grep nvidia; \
	done

test-llm: ## Test LLM endpoint
	@echo "Getting service endpoint..."
	@export LLM_IP=$$(kubectl get service llm-inference -n llm-inference -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null); \
	if [ -z "$$LLM_IP" ]; then \
		echo "Service not ready yet. Run 'make status' to check."; \
	else \
		echo "Testing endpoint: http://$$LLM_IP"; \
		curl -s http://$$LLM_IP/health || curl -s http://$$LLM_IP/v1/models | jq .; \
	fi

scale-gpu: ## Scale GPU nodes (usage: make scale-gpu NODES=2)
	@if [ -z "$(NODES)" ]; then \
		echo "Usage: make scale-gpu NODES=<number>"; \
		exit 1; \
	fi
	gcloud container clusters resize $$(terraform output -raw cluster_name) \
		--node-pool gpu-pool \
		--num-nodes $(NODES) \
		--region $$(terraform output -raw cluster_region)

clean: ## Clean up Kubernetes resources
	kubectl delete namespace llm-inference --ignore-not-found=true

validate: ## Validate Terraform configuration
	terraform validate
	terraform fmt -check

format: ## Format Terraform files
	terraform fmt -recursive

