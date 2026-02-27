module "gke_cluster" {
  source = "../../"

  project_id   = "example-project-id"
  cluster_name = "example-gke-cluster"
  region       = "us-central1"

  network_name        = "example-vpc"
  subnet_name         = "example-subnet"
  pods_range_name     = "pods"
  services_range_name = "services"

  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = "172.16.0.0/28"

  labels = {
    environment = "dev"
    team        = "platform"
  }
}
