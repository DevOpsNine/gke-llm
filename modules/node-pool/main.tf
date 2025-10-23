# Node Pool Module - Supports both CPU and GPU node pools

resource "google_container_node_pool" "node_pool" {
  name       = var.node_pool_name
  location   = var.region
  cluster    = var.cluster_name
  project    = var.project_id
  node_count = var.node_count
  
  # Specify zones where GPUs are available
  node_locations = var.node_locations

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    # GPU configuration (optional)
    dynamic "guest_accelerator" {
      for_each = var.gpu_type != "" ? [1] : []
      content {
        type  = var.gpu_type
        count = var.gpu_count
        gpu_driver_installation_config {
          gpu_driver_version = var.gpu_driver_version
        }
      }
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = var.labels

    # GPU taint (if GPU is present)
    dynamic "taint" {
      for_each = var.gpu_type != "" ? [1] : []
      content {
        key    = "nvidia.com/gpu"
        value  = "present"
        effect = "NO_SCHEDULE"
      }
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = var.enable_secure_boot
      enable_integrity_monitoring = var.enable_integrity_monitoring
    }

    spot = var.enable_spot_instances
  }

  # Autoscaling (optional)
  dynamic "autoscaling" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
    }
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }
}

