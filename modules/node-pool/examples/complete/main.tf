module "node_pool" {
  source = "../../"

  project_id     = "example-project-id"
  node_pool_name = "example-cpu-pool"
  region         = "us-central1"
  cluster_name   = "example-gke-cluster"

  machine_type   = "n1-standard-4"
  node_count     = 1
  min_node_count = 1
  max_node_count = 3

  disk_size_gb = 50
  disk_type    = "pd-balanced"

  enable_spot_instances = true
  enable_autoscaling    = true

  labels = {
    workload    = "batch"
    environment = "dev"
  }
}
