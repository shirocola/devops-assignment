terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"  # Adjust based on your requirements
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable necessary APIs
resource "google_project_service" "container_api" {
  service = "container.googleapis.com"
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "gke-vpc-network"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

# Create a GKE cluster with Workload Identity enabled
resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = var.region

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# Create a node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = false
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"  # Ensure this is compatible with your provider version
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Create a GCP service account for Workload Identity
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-sa"
  display_name = "GKE Service Account"
}

# Bind roles to the service account (example role)
resource "google_project_iam_member" "service_account_role" {
  project = var.project_id
  role    = "roles/storage.admin"  # Replace with the required role
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}
