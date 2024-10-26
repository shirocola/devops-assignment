# variables.tf

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "devops-assignment-439616"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone for the GKE cluster"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "hello-api-cluster"
}

variable "network_name" {
  description = "VPC Network Name"
  type        = string
  default     = "hello-api-network"
}


