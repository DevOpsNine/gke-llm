# Istio Service Mesh Installation
# This file installs Istio Gateway and control plane using Helm

# Initialize Helm and add Istio repository
resource "null_resource" "helm_repo_add" {
  provisioner "local-exec" {
    command = <<-EOT
      helm repo add istio https://istio-release.storage.googleapis.com/charts
      helm repo update
    EOT
  }

  depends_on = [null_resource.get_cluster_credentials]
}

# Add Istio Helm repository
resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true

  depends_on = [null_resource.helm_repo_add]
}

# Install Istiod (Istio control plane)
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = "1.20.0" # Specify Istio version

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }

  depends_on = [helm_release.istio_base]
}

# Install Istio Gateway (Ingress Gateway)
resource "helm_release" "istio_gateway" {
  name       = "istio-gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = "istio-system"
  version    = "1.20.0" # Match Istio version

  set {
    name  = "service.type"
    value = "LoadBalancer" # Use LoadBalancer for external access
  }

  set {
    name  = "service.annotations.cloud\\.google\\.com/load-balancer-type"
    value = "External"
  }

  depends_on = [helm_release.istiod]
}