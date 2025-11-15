terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Configure Kubernetes and Helm providers to connect to GKE cluster
# These use the default kubeconfig file (~/.kube/config)

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

# Get cluster credentials before installing Istio
resource "null_resource" "get_cluster_credentials" {
  provisioner "local-exec" {
    command = <<-EOT
      gcloud container clusters get-credentials ${var.project_name}-gke-cluster \
        --region ${var.region} \
        --project ${var.project_id}
    EOT
  }

  triggers = {
    cluster_id = module.gke_cluster.cluster_id
  }

  depends_on = [module.cpu_node_pool]
}