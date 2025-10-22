# Root Outputs Configuration

# Cluster Outputs
output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true
}

output "cluster_region" {
  description = "GKE cluster region"
  value       = module.gke_cluster.cluster_location
}

# Network Outputs
output "network_name" {
  description = "VPC network name"
  value       = module.network.network_name
}

output "subnet_name" {
  description = "Subnet name"
  value       = module.network.subnet_name
}

# Node Pool Outputs
output "cpu_node_pool_name" {
  description = "CPU node pool name"
  value       = module.cpu_node_pool.node_pool_name
}

output "gpu_node_pool_name" {
  description = "GPU node pool name"
  value       = module.gpu_node_pool.node_pool_name
}

# Connection Command
output "kubectl_connection_command" {
  description = "Command to connect kubectl to the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id}"
}

# GPU Information
output "gpu_type" {
  description = "GPU type attached to nodes"
  value       = var.gpu_type
}

output "gpu_count_per_node" {
  description = "Number of GPUs per node"
  value       = var.gpu_count_per_node
}

# Project Information
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}
