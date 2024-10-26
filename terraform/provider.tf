# provider.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = "us-central1-a"    # Specify the zone here
  credentials = file("./devops-assignment-439616-69270a783cda.json")
}
