variable "project_id" {
  description = "GCP Project ID"
  type = string
}

variable "region" {
  description = "GCP Region"
  type = string
  default = "asia-southeast1"
}

variable "node_count" {
  description = "Number of nodes in node pool"
  type = number
  default = 3
}