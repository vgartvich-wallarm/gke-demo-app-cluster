
resource "helm_release" "sqlmap-dvwa" {
  name  = "tf-sqlmap-dvwa"
  chart = "sqlmap"

  set_string {
    name  = "test_url"
    value = "http://dvwa.${var.dns_zone}/login.php"
  }

  set_string {
    name  = "schedule"
    value = "*/3 * * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }
}

resource "helm_release" "sqlmap-suitecrm" {
  name  = "tf-sqlmap-suitecrm"
  chart = "sqlmap"

  set_string {
    name  = "test_url"
    value = "http://suitecrm.${var.dns_zone}/index.php?action=Login&module=Users"
  }

  set_string {
    name  = "schedule"
    value = "12 */2 * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }
}


resource "helm_release" "sqlmap-grafana" {
  name  = "tf-sqlmap-grafana"
  chart = "sqlmap"

  set_string {
    name  = "test_url"
    value = "https://grafana.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "*/7 * * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }
}
