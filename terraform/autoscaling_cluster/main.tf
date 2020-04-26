provider "google" {
  credentials = var.credentials
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc-network" {
  name = "tf-autoscaling-cluster"
}

resource "google_compute_autoscaler" "waf-cluster" {
  name   = "tf-waf-cluster"
  project = var.project_id
  target = google_compute_instance_group_manager.waf-cluster.self_link

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_instance_template" "waf-cluster" {
  name           = "tf-waf-instance-template"
  machine_type   = var.waf_node_machine_type
  can_ip_forward = false
  project = var.project_id

  disk {
    source_image = data.google_compute_image.centos_7.self_link
  }

  network_interface {
    network = google_compute_network.vpc-network.name
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "waf-cluster" {
  name = "tf-waf-target-pool"
  project = var.project_id
  region = var.region
}

resource "google_compute_instance_group_manager" "waf-cluster" {
  name = "tf-waf-igm"
  project = var.project_id
  version {
    instance_template  = google_compute_instance_template.waf-cluster.self_link
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.waf-cluster.self_link]
  base_instance_name = "tf-waf-cluster"
}

data "google_compute_image" "centos_7" {
  family  = "centos-7"
  project = "centos-cloud"
}

module "lb" {
  source  = "GoogleCloudPlatform/lb/google"
  version = "2.2.0"
  region       = var.region
  name         = "tf-waf-cluster-load-balancer"
  service_port = 80
  target_tags  = ["waf-cluster"]
  network      = google_compute_network.vpc-network.name
}
