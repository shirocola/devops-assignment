# terraform/argocd/variables.tf
variable "namespace" {
  description = "Namespace สำหรับติดตั้ง ArgoCD"
  type        = string
  default     = "argocd"
}
