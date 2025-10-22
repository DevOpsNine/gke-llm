variable "project_id" {
  description = "GCP Project ID"
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

variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "pods_cidr" {
  description = "CIDR range for pods"
  type        = string
}

variable "services_cidr" {
  description = "CIDR range for services"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary IP range for pods"
  type        = string
  default     = "pods"
}

variable "services_range_name" {
  description = "Name of the secondary IP range for services"
  type        = string
  default     = "services"
}

