variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "node_locations" {
  description = "List of zones to create nodes in. Leave empty for all zones in region."
  type        = list(string)
  default     = []
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the nodes"
  type        = string
}

variable "node_count" {
  description = "Initial number of nodes"
  type        = number
}

variable "min_node_count" {
  description = "Minimum number of nodes"
  type        = number
}

variable "max_node_count" {
  description = "Maximum number of nodes"
  type        = number
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Disk type (pd-standard or pd-ssd)"
  type        = string
  default     = "pd-standard"
}

variable "labels" {
  description = "Labels to apply to the nodes"
  type        = map(string)
  default     = {}
}

# Node Configuration
variable "enable_spot_instances" {
  description = "Enable spot/preemptible instances"
  type        = bool
  default     = false
}

variable "enable_secure_boot" {
  description = "Enable secure boot"
  type        = bool
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Enable integrity monitoring"
  type        = bool
  default     = true
}

variable "auto_repair" {
  description = "Enable auto repair"
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "Enable auto upgrade"
  type        = bool
  default     = true
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the node pool"
  type        = bool
  default     = false
}

