

resource "helm_release" "wordpress" {
  name  = "tf-wordpress"
  chart = "wordpress"

  set {
    name  = "persistence.enabled"
    value = "false"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set_string {
    name  = "ingress.hostname"
    value = "wp.${var.dns_zone}"
  }

  set_string {
    name  = "service.type"
    value = "ClusterIP"
  }

  set_string {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "wallarm-ingress"
  }

  set_string {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/wallarm-mode"
    value = "$wallarm_mode_real"
  }

  set_string {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/wallarm-instance"
    value = "6"
  }
}
