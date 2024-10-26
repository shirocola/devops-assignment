# terraform/app/outputs.tf
output "app_name" {
  description = "ชื่อของแอปพลิเคชันใน ArgoCD"
  value       = var.app_name
}

output "app_namespace" {
  description = "Namespace ของแอปพลิเคชันที่ deploy ใน Kubernetes"
  value       = var.app_namespace
}
