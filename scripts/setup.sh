#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}GKE LLM Deployment Setup${NC}"
echo "=================================="

# Check if required tools are installed
echo -e "\n${YELLOW}1. Checking prerequisites...${NC}"

command -v gcloud >/dev/null 2>&1 || {
    echo -e "${RED}Error: gcloud is not installed.${NC}"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
}
echo -e "${GREEN}✓ gcloud CLI installed${NC}"

command -v terraform >/dev/null 2>&1 || {
    echo -e "${RED}Error: terraform is not installed.${NC}"
    echo "Install from: https://www.terraform.io/downloads"
    exit 1
}
echo -e "${GREEN}✓ Terraform installed${NC}"

command -v kubectl >/dev/null 2>&1 || {
    echo -e "${RED}Error: kubectl is not installed.${NC}"
    echo "Run: gcloud components install kubectl"
    exit 1
}
echo -e "${GREEN}✓ kubectl installed${NC}"

# Check if terraform.tfvars exists
echo -e "\n${YELLOW}2. Checking configuration...${NC}"
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}Please edit terraform.tfvars with your project details and run this script again.${NC}"
    exit 0
fi
echo -e "${GREEN}✓ terraform.tfvars exists${NC}"

# Extract project ID from tfvars
PROJECT_ID=$(grep '^project_id' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
REGION=$(grep '^region' terraform.tfvars | cut -d'=' -f2 | tr -d ' "' || echo "us-central1")

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: project_id not set in terraform.tfvars${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Project ID: $PROJECT_ID${NC}"
echo -e "${GREEN}✓ Region: $REGION${NC}"

# Set gcloud project
echo -e "\n${YELLOW}3. Setting gcloud project...${NC}"
gcloud config set project "$PROJECT_ID"

# Enable required APIs
echo -e "\n${YELLOW}4. Enabling required GCP APIs...${NC}"
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable servicenetworking.googleapis.com
echo -e "${GREEN}✓ APIs enabled${NC}"

# Check GPU quota
echo -e "\n${YELLOW}5. Checking GPU quota...${NC}"
echo "Current GPU quotas in $REGION:"
gcloud compute regions describe "$REGION" --format="table(quotas.filter(metric:nvidia))" 2>/dev/null || \
    echo -e "${YELLOW}Note: Run 'gcloud compute regions describe $REGION' to check quotas${NC}"

# Initialize Terraform
echo -e "\n${YELLOW}6. Initializing Terraform...${NC}"
terraform init
echo -e "${GREEN}✓ Terraform initialized${NC}"

# Validate configuration
echo -e "\n${YELLOW}7. Validating Terraform configuration...${NC}"
terraform validate
echo -e "${GREEN}✓ Configuration valid${NC}"

# Summary
echo -e "\n${GREEN}=================================="
echo -e "Setup complete! ✓${NC}"
echo -e "=================================="
echo -e "\nNext steps:"
echo -e "1. Review the plan: ${YELLOW}make plan${NC}"
echo -e "2. Deploy infrastructure: ${YELLOW}make apply${NC}"
echo -e "3. Connect to cluster: ${YELLOW}make connect${NC}"
echo -e "4. Deploy LLM: ${YELLOW}make deploy-llm${NC}"
echo -e "5. Test deployment: ${YELLOW}make test-llm${NC}"
echo -e "\nOr run the full deployment:"
echo -e "${YELLOW}./scripts/deploy.sh${NC}"

