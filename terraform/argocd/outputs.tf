# terraform/argocd/outputs.tf
output "argocd_url" {
  description = "URL ของ ArgoCD สำหรับเข้าถึง UI"
  value       = helm_release.argocd.status.load_balancer[0].ingress[0].hostname
}

output "argocd_namespace" {
  description = "Namespace ของ ArgoCD ที่ติดตั้งใน Kubernetes"
  value       = var.namespace
}
