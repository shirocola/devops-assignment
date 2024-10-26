# terraform/app/variables.tf
variable "app_name" {
  description = "ชื่อของแอปพลิเคชันใน ArgoCD"
  type        = string
  default     = "hello-api"
}

variable "argocd_namespace" {
  description = "Namespace ของ ArgoCD"
  type        = string
  default     = "argocd"
}

variable "repo_url" {
  description = "URL ของ Git repository"
  type        = string
  default     = "https://github.com/shirocola/devops-assignment.git"
}

variable "target_revision" {
  description = "Branch หรือ commit ที่ต้องการ deploy"
  type        = string
  default     = "HEAD"
}

variable "path" {
  description = "Path ของ manifests ใน repo"
  type        = string
  default     = "k8s/overlays/prod"
}

variable "app_namespace" {
  description = "Namespace สำหรับแอปพลิเคชัน"
  type        = string
  default     = "hello-api-namespace"
}

variable "cluster_server" {
  description = "Kubernetes cluster server endpoint"
  type        = string
}

