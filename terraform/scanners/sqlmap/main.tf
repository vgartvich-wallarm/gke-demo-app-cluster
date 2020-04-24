
resource "helm_release" "sqlmap-dvwa" {
  name  = "tf-sqlmap-dvwa"
  chart = "sqlmap"

  set_string {
    name  = "test_url"
    value = "http://dvwa.${var.dns_zone}/login.php"
  }

  set_string {
    name  = "schedule"
    value = "3 * * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }

  set_string {
    name  = "source_ip_address"
    value = "34.55.23.76"
  }
}
