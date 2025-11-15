#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}GKE Cluster Deployment Pipeline${NC}"
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

# Wait for Istio Gateway
echo -e "\n${YELLOW}Waiting for Istio Gateway LoadBalancer IP...${NC}"
echo "This may take a few minutes..."
for i in {1..60}; do
    GATEWAY_IP=$(kubectl get svc -n istio-system -l istio=ingressgateway -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ ! -z "$GATEWAY_IP" ]; then
        break
    fi
    echo -n "."
    sleep 5
done
echo ""

if [ -z "$GATEWAY_IP" ]; then
    echo -e "${YELLOW}LoadBalancer IP not yet assigned. Check status with: make istio-status${NC}"
else
    echo -e "${GREEN}✓ Istio Gateway IP: $GATEWAY_IP${NC}"
fi

# Show status
echo -e "\n${YELLOW}Deployment Status:${NC}"
make status

echo -e "\n${YELLOW}Istio Gateway Status:${NC}"
make istio-status

# Final message
echo -e "\n${GREEN}=================================="
echo -e "Deployment Complete! ✓${NC}"
echo -e "=================================="
echo -e "\nUseful commands:"
echo -e "  Check cluster status: ${YELLOW}make status${NC}"
echo -e "  Check Istio status: ${YELLOW}make istio-status${NC}"
echo -e "  Format Terraform: ${YELLOW}make format${NC}"

if [ ! -z "$GATEWAY_IP" ]; then
    echo -e "\n${GREEN}Istio Gateway IP: $GATEWAY_IP${NC}"
    echo -e "You can now deploy applications and route traffic through the Istio Gateway."
fi

