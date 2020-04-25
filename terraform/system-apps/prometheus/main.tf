resource "kubernetes_secret" "basic-auth" {
  metadata {
    name = "tf-prometheus-basic-auth"
  }

  data = {
    auth = "${var.prometheus_username}:${var.prometheus_encrypted_password}"
  }

  type = "Opaque"
}

resource "helm_release" "prometheus" {
  name  = "tf-prometheus"
  chart = "prometheus-operator"

  set {
    name = "prometheus.ingress.enabled"
    value = "true"
  }

  set_string {
    name  = "prometheus.ingress.tls[0].hosts[0]"
    value = "prometheus.${var.dns_zone}"
  }

  set_string {
    name  = "prometheus.ingress.tls[0].secretName"
    value = "prometheus-tls"
  }

  set_string {
    name  = "prometheus.ingress.hosts[0].name"
    value = "prometheus.${var.dns_zone}"
  }

  set_string {
    name  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-type"
    value = "basic"
  }

  set_string {
    name  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-secret"
    value = "tf-prometheus-basic-auth"
  }

  set_string {
    name  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-realm"
    value = "Authentication Required"
  }

  set {
    name  = "prometheus.ingress.annotations.kubernetes\\.io/force-ssl-redirect"
    value = "true"
  }

  set_string {
    name  = "prometheus.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "wallarm-ingress"
  }

  set_string {
    name  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/wallarm-mode"
    value = "$wallarm_mode_real"
  }

  set_string {
    name  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/wallarm-instance"
    value = "1"
  }

  set_string {
    name  = "prometheus.ingress.annotations.cert-manager\\.io/issuer"
    value = "letsencrypt-prod"
  }

  set {
    name = "alertmanager.ingress.enabled"
    value = "true"
  }

  set_string {
    name  = "alertmanager.ingress.hosts[0].name"
    value = "alertmanager.${var.dns_zone}"
  }

  set_string {
    name  = "alertmanager.ingress.tls[0].hosts[0]"
    value = "alertmanager.${var.dns_zone}"
  }

  set_string {
    name  = "alertmanager.ingress.tls[0].secretName"
    value = "alertmanager-tls"
  }

  set_string {
    name  = "alertmanager.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-type"
    value = "basic"
  }

  set_string {
    name  = "alertmanager.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-secret"
    value = "tf-prometheus-basic-auth"
  }

  set_string {
    name  = "alertmanager.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-realm"
    value = "Authentication Required"
  }

  set {
    name  = "alertmanager.ingress.annotations.kubernetes\\.io/force-ssl-redirect"
    value = "true"
  }

  set_string {
    name  = "alertmanager.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "wallarm-ingress"
  }

  set_string {
    name  = "alertmanager.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/wallarm-mode"
    value = "$wallarm_mode_real"
  }

  set_string {
    name  = "alertmanager.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/wallarm-instance"
    value = "1"
  }

  set_string {
    name  = "alertmanager.ingress.annotations.cert-manager\\.io/issuer"
    value = "letsencrypt-prod"
  }
}
