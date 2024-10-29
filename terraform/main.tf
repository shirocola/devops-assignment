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
  location           = var.zone                     # Set to a specific zone for a zonal cluster
  network            = google_compute_network.vpc_network.id
  subnetwork         = google_compute_subnetwork.subnet.id
  initial_node_count = 2                            # Reduced node count

  # Enable Workload Identity
  workload_identity_config {}

  # Node Pool Config
  node_config {
    machine_type = "e2-small"                       # Smaller machine type to fit quota
    disk_size_gb = 20                               # Lower disk size to fit within quota
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}

# Secret Management
data "google_secret_manager_secret_version" "my_secret" {
  secret = "MY_SECRET"
}

resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "e2-medium"
  zone         = var.zone                          # Use the variable for zone

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"            # Specify a boot disk image
      size  = 10                                   # Size in GB
    }
  }

  # Network interface configuration
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    my_secret_key = data.google_secret_manager_secret_version.my_secret.secret_data
  }
}

resource "google_compute_firewall" "k8s_fw" {
  name    = "k8s-fw"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
