
resource "helm_release" "grafana" {
  name  = "tf-grafana"
  chart = "grafana"

  set_string {
    name = "admin.password"
    value = var.grafana_password
  }

  set {
    name = "metrics.enabled"
    value = "true"
  }

  set {
    name = "metrics.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name = "ingress.enabled"
    value = "true"
  }

  set_string {
    name  = "ingress.hosts[0].name"
    value = "grafana.${var.dns_zone}"
  }

  set {
    name  = "ingress.hosts[0].tls"
    value = "true"
  }

  set_string {
    name  = "ingress.hosts[0].tlsSecret"
    value = "grafana-tls"
  }

  set_string {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/force-ssl-redirect"
    value = "true"
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
    value = "1"
  }

  set_string {
    name  = "ingress.annotations.cert-manager\\.io/issuer"
    value = "letsencrypt-prod"
  }
}
