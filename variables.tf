# Root Variables Configuration

# Project Configuration
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "gke-cluster"
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

# Network Configuration
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  description = "CIDR range for pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "CIDR range for services"
  type        = string
  default     = "10.2.0.0/16"
}

# GKE Cluster Configuration
variable "maintenance_start_time" {
  description = "Start time for daily maintenance window (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "enable_shielded_nodes" {
  description = "Enable shielded nodes"
  type        = bool
  default     = true
}

variable "logging_service" {
  description = "Logging service to use"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "Monitoring service to use"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

# CPU Node Pool Configuration
variable "cpu_machine_type" {
  description = "Machine type for CPU node pool"
  type        = string
  default     = "n1-standard-4"
}

variable "cpu_node_count" {
  description = "Initial number of CPU nodes"
  type        = number
  default     = 2
}

variable "cpu_min_nodes" {
  description = "Minimum number of CPU nodes"
  type        = number
  default     = 1
}

variable "cpu_max_nodes" {
  description = "Maximum number of CPU nodes"
  type        = number
  default     = 3
}

variable "cpu_enable_spot" {
  description = "Enable spot/preemptible instances for CPU nodes"
  type        = bool
  default     = false
}

variable "cpu_node_locations" {
  description = "Specific zones for CPU nodes (e.g., [\"us-central1-a\"]). Leave empty for all zones."
  type        = list(string)
  default     = []
}

# Private Cluster Configuration
variable "enable_private_nodes" {
  description = "Enable private nodes (nodes will not have external IP addresses)"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint (control plane will not be accessible from internet)"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of master authorized networks that can access the cluster endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  ]
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the cluster. Set to false to allow deletion."
  type        = bool
  default     = false
}
