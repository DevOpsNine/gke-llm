# Main Terraform Configuration - GKE Cluster with Istio Gateway
# This file orchestrates all modules

# Network Module
module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  network_name = "${var.project_name}-vpc"
  subnet_name  = "${var.project_name}-subnet"
  region       = var.region

  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

# GKE Cluster Module
module "gke_cluster" {
  source = "./modules/gke-cluster"

  project_id      = var.project_id
  cluster_name    = "${var.project_name}-gke-cluster"
  region          = var.region
  network_name    = module.network.network_name
  subnet_name     = module.network.subnet_name
  pods_range_name = module.network.pods_range_name
  services_range_name = module.network.services_range_name

  maintenance_start_time = var.maintenance_start_time
  enable_shielded_nodes  = var.enable_shielded_nodes
  logging_service        = var.logging_service
  monitoring_service     = var.monitoring_service

  # Private cluster configuration
  enable_private_nodes        = var.enable_private_nodes
  enable_private_endpoint     = var.enable_private_endpoint
  master_ipv4_cidr_block      = var.master_ipv4_cidr_block
  master_authorized_networks  = var.master_authorized_networks
  
  # Deletion protection
  deletion_protection = var.deletion_protection

  depends_on = [module.network]
}

# CPU Node Pool Module
module "cpu_node_pool" {
  source = "./modules/node-pool"

  project_id     = var.project_id
  node_pool_name = "cpu-pool"
  region         = var.region
  cluster_name   = module.gke_cluster.cluster_name

  machine_type   = var.cpu_machine_type
  node_count     = var.cpu_node_count
  min_node_count = var.cpu_min_nodes
  max_node_count = var.cpu_max_nodes

  disk_size_gb = 100
  disk_type    = "pd-balanced"

  labels = {
    workload = "general"
  }

  enable_spot_instances = var.cpu_enable_spot
  enable_autoscaling    = true
  
  # Specify zones for CPU nodes
  node_locations = var.cpu_node_locations

  depends_on = [module.gke_cluster]
}