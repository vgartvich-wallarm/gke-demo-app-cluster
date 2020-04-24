

resource "helm_release" "suitecrm" {
  name  = "tf-suitecrm"
  chart = "suitecrm"

  set {
    name  = "mariadb.master.persistence.enabled"
    value = "false"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set_string {
    name  = "ingress.hosts[0].name"
    value = "suitecrm.${var.dns_zone}"
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
    value = "7"
  }

  set_string {
    name  = "suitecrmUsername"
    value = var.suitecrm_username
  }

  set_sensitive {
    name  = "suitecrmPassword"
    value = var.suitecrm_password
  }
}
