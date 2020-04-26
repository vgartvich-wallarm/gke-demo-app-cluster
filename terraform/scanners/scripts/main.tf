
resource "helm_release" "scripts" {
  name  = "tf-scripts"
  chart = "scripts"

  set_string {
    name  = "domain_name"
    value = var.dns_zone
  }

  set_string {
    name  = "schedule"
    value = "*/4 * * * *"
  }

  set_string {
    name  = "delay"
    value = "120"
  }
}

