# Main Terraform Configuration - LLM on GKE with GPU
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
  disk_type    = "pd-standard"

  labels = {
    workload = "general"
  }

  enable_spot_instances = var.cpu_enable_spot

  depends_on = [module.gke_cluster]
}

# GPU Node Pool Module
module "gpu_node_pool" {
  source = "./modules/node-pool"

  project_id     = var.project_id
  node_pool_name = "gpu-pool"
  region         = var.region
  cluster_name   = module.gke_cluster.cluster_name

  machine_type   = var.gpu_machine_type
  node_count     = var.gpu_node_count
  min_node_count = var.gpu_min_nodes
  max_node_count = var.gpu_max_nodes

  disk_size_gb = 200
  disk_type    = "pd-ssd"

  # GPU configuration
  gpu_type           = var.gpu_type
  gpu_count          = var.gpu_count_per_node
  gpu_driver_version = var.gpu_driver_version

  labels = {
    workload = "gpu-llm"
  }

  enable_spot_instances = var.gpu_enable_spot

  depends_on = [module.gke_cluster]
}

# Install NVIDIA GPU device plugin
resource "null_resource" "install_nvidia_driver" {
  depends_on = [module.gpu_node_pool]

  provisioner "local-exec" {
    command = <<-EOT
      gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} \
        --region ${var.region} \
        --project ${var.project_id}
      
      kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded-latest.yaml
    EOT
  }

  triggers = {
    cluster_id = module.gke_cluster.cluster_id
  }
}
