data "terraform_remote_state" "dns" {
    backend = "local"
    config = {
      path = "../../dns/terraform.tfstate"
    }
}

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
     image = var.wallarm_gcp_node_image
   }
 }

  metadata = {
   ssh-keys = "${var.ssh_username}:${file(var.ssh_pub_key_file)}"
  }

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata_startup_script = <<-EOF
apt-get update -y
apt-get install less wget tcpdump -y
wget -O splunk-8.0.3-a6754d8441bf-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.3&product=splunk&filename=splunk-8.0.3-a6754d8441bf-linux-2.6-amd64.deb&wget=true'
dpkg -i splunk-8.0.3-a6754d8441bf-linux-2.6-amd64.deb
/usr/share/wallarm-common/addnode --force  -u ${var.waf_node_deploy_username} -p ${var.waf_node_deploy_password} -H ${var.api_host} --batch

cat << SPLUNKUI > /etc/nginx/conf.d/wallarm-splunk-ui.conf
server {
      listen 80;

      server_name splunk.${var.dns_zone};

      # turn on the monitoring mode of traffic processing
      wallarm_mode block;
      wallarm_instance 11;

      location / {
        # setting the address for request forwarding
        proxy_pass http://localhost:8000; 
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      }
}
SPLUNKUI

cat << SPLUNKAPI > /etc/nginx/conf.d/wallarm-splunk-api.conf
server {
      listen 88;

      server_name splunk.${var.dns_zone};

      # turn on the monitoring mode of traffic processing
      wallarm_mode block;
      wallarm_instance 11;

      location / {
        # setting the address for request forwarding
        proxy_pass http://localhost:8088;         
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      }
}

SPLUNKAPI
service nginx configtest
service nginx restart
service nginx start
EOF

}

resource "google_compute_firewall" "default" {
 name    = "tf-splunk-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["80"]
 }

 allow {
   protocol = "tcp"
   ports    = ["88"]
 }
}

resource "google_dns_record_set" "splunk" {
  name = "splunk.${var.dns_zone}."
  type = "A"
  ttl  = 10

  # managed_zone = data.terraform_remote_state.dns.google_dns_managed_zone.demo_wallarm_com_dns_zone.name
  managed_zone = data.terraform_remote_state.dns.outputs.google_dns_managed_zone_name

  rrdatas = [google_compute_instance.splunk.network_interface[0].access_config[0].nat_ip]
}

output "ip" {
 value = google_compute_instance.splunk.network_interface.0.access_config.0.nat_ip
}
