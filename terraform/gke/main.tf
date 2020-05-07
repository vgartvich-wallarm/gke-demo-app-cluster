provider "google" {
  credentials = var.credentials
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name               = "tf-gke-demo-app-cluster"
  location           = var.zone
  initial_node_count = 1

  cluster_autoscaling {
    enabled = false
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    preemptible = true
    machine_type       = var.machine_type
    disk_size_gb = var.disk_size_gb
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_container_node_pool" "np" {
  name       = "tf-gke-demo-app-cluster-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  initial_node_count = var.initial_node_count

  node_config {
    preemptible = true
    machine_type       = var.machine_type
    disk_size_gb = var.disk_size_gb
  }

  autoscaling {
    min_node_count          = var.min_count
    max_node_count          = var.max_count
  }
 
  timeouts {
    create = "30m"
    update = "20m"
  }
}

output "zone" {
  value = var.zone
}
