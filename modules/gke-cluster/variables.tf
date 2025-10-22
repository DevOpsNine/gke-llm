variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary IP range for pods"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary IP range for services"
  type        = string
}

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
  description = "List of master authorized networks"
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

