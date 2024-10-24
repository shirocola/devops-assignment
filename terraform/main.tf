# Specify the required Terraform version and provider version
terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.79.0"  # Latest version as of October 2023
    }
  }
}

# Configure the Google provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable necessary GCP APIs
resource "google_project_service" "project_services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])
  service = each.key
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "gke-vpc-network"
  auto_create_subnetworks = false
}

# Create a subnet in the VPC network
resource "google_compute_subnetwork" "subnet" {
  name                     = "gke-subnet"
  ip_cidr_range            = "10.0.0.0/16"
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

# Create a GKE cluster with Workload Identity enabled
resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = var.region

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Set the release channel
  release_channel {
    channel = "REGULAR"
  }

  # Enable network policy
  network_policy {
    enabled = true
  }

  # Enable logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}

# Create a node pool for the GKE cluster
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible     = false
    machine_type    = "e2-medium"
    service_account = google_service_account.gke_node_service_account.email

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      environment = "production"
    }

    tags = ["gke-node", "hello-api"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

# Create a GCP service account for GKE nodes
resource "google_service_account" "gke_node_service_account" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

# Assign roles to the node service account
resource "google_project_iam_member" "node_sa_logging_role" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}

resource "google_project_iam_member" "node_sa_monitoring_role" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}

# Create a GCP service account for workloads
resource "google_service_account" "gke_workload_service_account" {
  account_id   = "gke-workload-sa"
  display_name = "GKE Workload Service Account"
}

# Assign necessary roles to the workload service account
resource "google_project_iam_member" "workload_sa_role" {
  project = var.project_id
  role    = "roles/storage.admin"  # Replace with the required role for your application
  member  = "serviceAccount:${google_service_account.gke_workload_service_account.email}"
}

# Bind Kubernetes Service Account to GCP Service Account for Workload Identity
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.gke_workload_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[hello-api-namespace/hello-api-sa]"
}
