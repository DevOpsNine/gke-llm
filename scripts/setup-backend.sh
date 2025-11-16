#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Setting up Terraform GCS Backend${NC}"
echo "=================================="

# Get project ID from terraform.tfvars
PROJECT_ID=$(grep '^project_id' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
REGION=$(grep '^region' terraform.tfvars | cut -d'=' -f2 | tr -d ' "' || echo "us-east4")

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: project_id not found in terraform.tfvars${NC}"
    exit 1
fi

# Bucket name (must be globally unique)
BUCKET_NAME="${PROJECT_ID}-terraform-state"

echo -e "\n${YELLOW}Project ID: ${GREEN}$PROJECT_ID${NC}"
echo -e "${YELLOW}Region: ${GREEN}$REGION${NC}"
echo -e "${YELLOW}Bucket Name: ${GREEN}$BUCKET_NAME${NC}"

# Check if bucket already exists
if gsutil ls -b gs://${BUCKET_NAME} &>/dev/null; then
    echo -e "\n${GREEN}✓ Bucket already exists: gs://${BUCKET_NAME}${NC}"
else
    echo -e "\n${YELLOW}Creating GCS bucket for Terraform state...${NC}"
    
    # Create bucket with versioning and encryption
    gsutil mb -p ${PROJECT_ID} -l ${REGION} -b on gs://${BUCKET_NAME}
    
    # Enable versioning (for state history and rollback)
    gsutil versioning set on gs://${BUCKET_NAME}
    
    # Enable uniform bucket-level access (security best practice)
    gsutil uniformbucketlevelaccess set on gs://${BUCKET_NAME}
    
    # Set lifecycle rule to keep only last 10 versions
    cat > /tmp/lifecycle.json <<EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "numNewerVersions": 10,
          "isLive": false
        }
      }
    ]
  }
}
EOF
    gsutil lifecycle set /tmp/lifecycle.json gs://${BUCKET_NAME}
    rm /tmp/lifecycle.json
    
    echo -e "${GREEN}✓ Bucket created and configured${NC}"
fi

# Set appropriate IAM permissions (optional - adjust as needed)
echo -e "\n${YELLOW}Setting IAM permissions...${NC}"
# Grant current user storage admin on the bucket
USER_EMAIL=$(gcloud config get-value account)
gsutil iam ch user:${USER_EMAIL}:objectAdmin gs://${BUCKET_NAME} || true

echo -e "\n${GREEN}=================================="
echo -e "Backend Setup Complete! ✓${NC}"
echo -e "=================================="

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Update provider.tf with backend configuration"
echo -e "2. Run: ${GREEN}terraform init -migrate-state${NC}"
echo -e "3. Confirm state migration when prompted"
echo -e "\n${YELLOW}Backend configuration to add to provider.tf:${NC}"
echo -e "${GREEN}"
cat <<EOF
terraform {
  backend "gcs" {
    bucket = "${BUCKET_NAME}"
    prefix = "terraform/state"
  }
}
EOF
echo -e "${NC}"

