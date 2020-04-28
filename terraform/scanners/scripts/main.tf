
resource "helm_release" "scripts" {
  name  = "tf-scripts"
  chart = "scripts"

  set_string {
    name  = "domain_name"
    value = var.dns_zone
  }

  set_string {
    name  = "schedule"
    value = "*/45 * * * *"
  }

  set_string {
    name  = "schedule_zipbomb"
    value = "5 */2 * * *"
  }

  set_string {
    name  = "delay"
    value = "120"
  }
}

