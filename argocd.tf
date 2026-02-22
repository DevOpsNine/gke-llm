# Initialize Helm and add ArgoCD repository
resource "null_resource" "argo_helm_repo_add" {
  provisioner "local-exec" {
    command = <<-EOT
      helm repo add argo https://argoproj.github.io/argo-helm
      helm repo update
    EOT
  }

  depends_on = [null_resource.get_cluster_credentials]
}

# ArgoCD Installation using Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "9.4.3" # Specify a stable version (using 7.7.0 as a modern stable version)

  set {
    name  = "server.service.type"
    value = "ClusterIP" # Use ClusterIP since we'll likely use Istio or another Ingress
  }

  # Add any other custom ArgoCD settings here
  # set {
  #   name  = "configs.params.server\\.insecure"
  #   value = "true"
  # }

  depends_on = [null_resource.argo_helm_repo_add]
}

# Data source to read the initial admin password secret
data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = helm_release.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}
