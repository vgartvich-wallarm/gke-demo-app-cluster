
resource "helm_release" "gotestwaf-dvwa" {
  name  = "tf-gotestwaf-dvwa"
  chart = "gotestwaf"

  set_string {
    name  = "test_url"
    value = "http://dvwa.${var.dns_zone}"
  }

  set_string {
    name  = "schedule"
    value = "*/30 */7 * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
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
    value = "*/45 */4 * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
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
    value = "*/45 */3 * * *"
  }

  set_string {
    name  = "delay"
    value = "55"
  }
}
