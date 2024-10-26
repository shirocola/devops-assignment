variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "node_count" {
  description = "Number of nodes in node pool"
  type        = number
  default     = 1
}

variable "argocd_namespace" {
  description = "Namespace to deploy ArgoCD"
  type        = string
  default     = "argocd"
}

variable "app_namespace" {
  description = "Namespace to deploy the application"
  type        = string
  default     = "hello-api-namespace"
}
