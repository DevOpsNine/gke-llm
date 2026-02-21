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

# Connection Command
output "kubectl_connection_command" {
  description = "Command to connect kubectl to the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id}"
}

# Project Information
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

# Istio Gateway Information
output "istio_gateway_namespace" {
  description = "Istio Gateway namespace"
  value       = "istio-system"
}

output "istio_gateway_service_name" {
  description = "Istio Gateway service name"
  value       = "istio-gateway"
}

output "istio_gateway_ip_command" {
  description = "Command to get Istio Gateway LoadBalancer IP"
  value       = "kubectl get svc istio-gateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
}

# Cloud SQL Outputs
output "db_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.cloud_sql.instance_name
}

output "db_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = module.cloud_sql.instance_connection_name
}

output "db_private_ip" {
  description = "Cloud SQL private IP address"
  value       = module.cloud_sql.private_ip_address
}

output "db_name" {
  description = "Default database name"
  value       = module.cloud_sql.db_name
}

output "db_user" {
  description = "Default database user"
  value       = module.cloud_sql.db_user
}
