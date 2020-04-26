
provider "google" {
  credentials = var.credentials
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "splunk" {
 name         = "tf-splunk"
 machine_type = var.splunk_machine_type
 zone         = var.zone

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

  metadata = {
   ssh-keys = "admin:${file("~/.ssh/id_rsa.pub")}"
  }

 # metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

resource "google_compute_firewall" "default" {
 name    = "tf-splunk-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["8000"]
 }
 allow {
   protocol = "tcp"
   ports    = ["8088"]
 }
}

output "ip" {
 value = google_compute_instance.splunk.network_interface.0.access_config.0.nat_ip
}
