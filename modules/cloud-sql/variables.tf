variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "database_version" {
  description = "The PostgreSQL version to use"
  type        = string
  default     = "POSTGRES_18"
  validation {
    condition     = can(regex("^POSTGRES_[0-9]+$", var.database_version))
    error_message = "Database version must follow format POSTGRES_X (e.g., POSTGRES_18)."
  }
}

variable "tier" {
  description = "The tier (machine type) for the database"
  type        = string
  default     = "db-f1-micro"
}

variable "network_id" {
  description = "The ID of the VPC network to connect to"
  type        = string
}

variable "db_name" {
  description = "Name of the default database to create"
  type        = string
  default     = "app_db"
}

variable "db_user" {
  description = "Name of the default database user"
  type        = string
  default     = "app_user"
}

variable "db_password" {
  description = "Password for the default database user"
  type        = string
  sensitive   = true
}

variable "availability_type" {
  description = "The availability type of the Cloud SQL instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the resources"
  type        = map(string)
  default     = {}
}
