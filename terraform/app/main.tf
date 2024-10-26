resource "kubernetes_manifest" "argocd_application" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = var.app_name
      "namespace" = var.argocd_namespace
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = var.repo_url
        "targetRevision" = var.target_revision
        "path"           = var.path
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = var.app_namespace
      }
      "syncPolicy" = {
        "automated" = {
          "prune"     = true
          "selfHeal"  = true
        }
      }
    }
  }
}
