# Terraform Backend Configuration - Google Cloud Storage
#
# This configuration stores Terraform state in GCS with:
# - State locking (prevents concurrent modifications)
# - Versioning (state history and rollback capability)
# - Encryption at rest (automatic with GCS)
#
# To enable remote backend:
# 1. Run: ./scripts/setup-backend.sh
# 2. Uncomment the backend block below
# 3. Run: terraform init -migrate-state
# 4. Confirm migration when prompted

# Uncomment after running setup-backend.sh:
terraform {
  backend "gcs" {
    bucket  = "secops-311714-terraform-state"  # Replace with your bucket name
    prefix  = "terraform/state"
  }
}

# Advanced backend configuration (optional):
# terraform {
#   backend "gcs" {
#     bucket                      = "secops-311714-terraform-state"
#     prefix                      = "terraform/state"
#     impersonate_service_account = ""  # Optional: use service account
#     encryption_key              = ""  # Optional: customer-managed encryption key
#   }
# }

