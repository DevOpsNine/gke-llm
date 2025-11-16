# Terraform Backend Configuration - Google Cloud Storage
#
# This configuration stores Terraform state in GCS with:
# - State locking (prevents concurrent modifications)
# - Versioning (state history and rollback capability)
# - Encryption at rest (automatic with GCS)
#
# Quick Setup:
# 1. Run: make backend-full (creates bucket and migrates state)
#
# Or step-by-step:
# 1. Run: make setup-backend (creates GCS bucket)
# 2. Run: make migrate-state (migrates local state to GCS)
#
# Check status:
# - Run: make backend-status

# Backend configuration (already enabled):
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

