# terraform/argocd/main.tf
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.namespace
  create_namespace = true

  values = [
    <<EOF
    server:
      service:
        type: LoadBalancer
    EOF
  ]
}
