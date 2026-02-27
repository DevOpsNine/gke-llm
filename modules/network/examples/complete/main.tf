module "network" {
  source = "../../"

  project_id   = "example-project-id"
  network_name = "example-vpc"
  subnet_name  = "example-subnet"
  region       = "us-central1"

  subnet_cidr   = "10.0.0.0/24"
  pods_cidr     = "10.1.0.0/16"
  services_cidr = "10.2.0.0/16"

  labels = {
    environment = "dev"
    team        = "platform"
  }
}
