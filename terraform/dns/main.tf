provider "google" {
  credentials = var.credentials
  project = var.project_id
  region  = var.region
}

resource "google_dns_managed_zone" "demo_wallarm_com_dns_zone" {
  name = "tf-wallarm-demo-com"
  dns_name = "${var.dns_zone}."
}

output "dns_servers" {
  value = "${google_dns_managed_zone.demo_wallarm_com_dns_zone.name_servers}"
}
