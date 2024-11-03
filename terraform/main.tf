# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/16"
}

# GKE Cluster (zonal)
resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.zone
  network            = google_compute_network.vpc_network.id
  subnetwork         = google_compute_subnetwork.subnet.id
  initial_node_count = 2

  # Enable Workload Identity
  workload_identity_config {}

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 20
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}

# Secret Management - Create Secret and Add a Version
resource "google_secret_manager_secret" "my_secret" {
  project      = var.project_id
  secret_id    = "MY_SECRET"
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
      replicas {
        location = "europe-west1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "my_secret_version" {
  secret      = google_secret_manager_secret.my_secret.id
  secret_data = var.secret_data
}

# Retrieve Secret Version for Use in Metadata
data "google_secret_manager_secret_version" "my_secret" {
  secret  = google_secret_manager_secret.my_secret.secret_id
  project = var.project_id
}

# Compute Instance Using the Secret
resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }

  # Network interface configuration
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata = {
    my_secret_key = data.google_secret_manager_secret_version.my_secret.secret_data
  }
}

# Firewall for Kubernetes Traffic
resource "google_compute_firewall" "k8s_fw" {
  name    = "k8s-fw"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
