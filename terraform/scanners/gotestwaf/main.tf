
resource "helm_release" "gotestwaf-dvwa" {
  name  = "tf-gotestwaf-dvwa"
  chart = "gotestwaf"

  set_string {
    name  = "test_url"
    value = "http://dvwa.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "5 * * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }

  set_string {
    name  = "source_ip_address"
    value = "221.129.247.24"
  }
}

resource "helm_release" "gotestwaf-wordpress" {
  name  = "tf-gotestwaf-wordpress"
  chart = "gotestwaf"

  set_string {
    name  = "test_url"
    value = "http://wp.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "15 * * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }

  set_string {
    name  = "source_ip_address"
    value = "36.19.47.4"
  }
}

resource "helm_release" "gotestwaf-suitecrm" {
  name  = "tf-gotestwaf-suitecrm"
  chart = "gotestwaf"

  set_string {
    name  = "test_url"
    value = "http://suitecrm.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "40 * * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }

  set_string {
    name  = "source_ip_address"
    value = "197.63.35.74"
  }
}
