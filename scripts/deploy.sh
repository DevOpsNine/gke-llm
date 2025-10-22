#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Full LLM Deployment Pipeline${NC}"
echo "=================================="

# Run setup
echo -e "\n${YELLOW}Running setup...${NC}"
./scripts/setup.sh

# Plan
echo -e "\n${YELLOW}Planning Terraform deployment...${NC}"
terraform plan -out=tfplan

# Confirm
echo -e "\n${YELLOW}Ready to deploy infrastructure.${NC}"
read -p "Continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Apply
echo -e "\n${YELLOW}Deploying infrastructure...${NC}"
terraform apply tfplan
rm tfplan

# Wait for cluster
echo -e "\n${YELLOW}Waiting for cluster to be ready...${NC}"
sleep 30

# Connect
echo -e "\n${YELLOW}Connecting to cluster...${NC}"
make connect

# Wait for nodes
echo -e "\n${YELLOW}Waiting for nodes to be ready...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=600s

# Deploy LLM
echo -e "\n${YELLOW}Deploying LLM...${NC}"
make deploy-llm

# Wait for service
echo -e "\n${YELLOW}Waiting for LoadBalancer IP...${NC}"
echo "This may take a few minutes..."
for i in {1..60}; do
    LLM_IP=$(kubectl get service llm-inference -n llm-inference -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ ! -z "$LLM_IP" ]; then
        break
    fi
    echo -n "."
    sleep 5
done
echo ""

if [ -z "$LLM_IP" ]; then
    echo -e "${YELLOW}LoadBalancer IP not yet assigned. Check status with: make status${NC}"
else
    echo -e "${GREEN}✓ LoadBalancer IP: $LLM_IP${NC}"
fi

# Show status
echo -e "\n${YELLOW}Deployment Status:${NC}"
make status

# Final message
echo -e "\n${GREEN}=================================="
echo -e "Deployment Complete! ✓${NC}"
echo -e "=================================="
echo -e "\nUseful commands:"
echo -e "  Check status: ${YELLOW}make status${NC}"
echo -e "  View logs: ${YELLOW}make logs${NC}"
echo -e "  Test LLM: ${YELLOW}make test-llm${NC}"
echo -e "  GPU check: ${YELLOW}make gpu-check${NC}"

if [ ! -z "$LLM_IP" ]; then
    echo -e "\nLLM Endpoint: ${GREEN}http://$LLM_IP${NC}"
    echo -e "\nWait a few minutes for the model to load, then test:"
    echo -e "${YELLOW}./scripts/test-llm.sh${NC}"
fi

