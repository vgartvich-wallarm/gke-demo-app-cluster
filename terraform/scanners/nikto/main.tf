
resource "helm_release" "nikto-wordpress" {
  name  = "tf-nikto-wordpress"
  chart = "nikto"

  set_string {
    name  = "test_url"
    value = "http://wp.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "2 * * * *"
  }

  set_string {
    name  = "delay"
    value = "120"
  }
}

resource "helm_release" "nikto-grafana" {
  name  = "tf-nikto-grafana"
  chart = "nikto"

  set_string {
    name  = "test_url"
    value = "https://grafana.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "4 * * * *"
  }

  set_string {
    name  = "delay"
    value = "120"
  }
}

