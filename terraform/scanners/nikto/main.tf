
resource "helm_release" "nikto-wordpress" {
  name  = "tf-nikto-wordpress"
  chart = "nikto"

  set_string {
    name  = "test_url"
    value = "http://wp.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "6 4 * * *"
  }

  set_string {
    name  = "delay"
    value = "120"
  }

  set_string {
    name  = "source_ip_address"
    value = "21.19.27.4"
  }
}

