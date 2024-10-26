output "argocd_url" {
  description = "URL ของ ArgoCD สำหรับเข้าถึง UI"
  value       = module.argocd.argocd_url
}

output "argocd_namespace" {
  description = "Namespace ของ ArgoCD ที่ติดตั้งใน Kubernetes"
  value       = module.argocd.namespace
}

output "app_name" {
  description = "ชื่อของแอปพลิเคชันใน ArgoCD"
  value       = module.app.app_name
}

output "app_namespace" {
  description = "Namespace ของแอปพลิเคชันที่ deploy ใน Kubernetes"
  value       = module.app.app_namespace
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}
