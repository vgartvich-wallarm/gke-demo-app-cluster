
resource "helm_release" "elasticsearch" {
  name  = "tf-elasticsearch"
  chart = "elasticsearch"

  set {
    name = "global.kibanaEnabled"
    value = "true"
  }

  set {
    name = "metrics.enabled"
    value = "true"
  }

  set {
    name = "metrics.serviceMonitor.enabled"
    value = "true"
  }
}

resource "kubernetes_ingress" "kibana" {
  metadata {
    name = "tf-kibana"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "$wallarm_mode_real"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "1"
       "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
       "cert-manager.io/issuer" = "letsencrypt-prod"
       "nginx.ingress.kubernetes.io/auth-type" = "basic"
       "nginx.ingress.kubernetes.io/auth-secret" = "tf-prometheus-basic-auth"
       "nginx.ingress.kubernetes.io/auth-realm" = "Authentication Required"
    }
  }

  spec {
    backend {
      service_name = "tf-elasticsearch-kibana"
      service_port = 80
    }
    tls {
      hosts = [ "kibana.${var.dns_zone}" ]
      secret_name = "kibana-tls"
    }

    rule {
      host = "kibana.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-elasticsearch-kibana"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_ingress" "es" {
  metadata {
    name = "tf-es"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "off"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "1"
       "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
       "cert-manager.io/issuer" = "letsencrypt-prod"
       "nginx.ingress.kubernetes.io/auth-type" = "basic"
       "nginx.ingress.kubernetes.io/auth-secret" = "tf-prometheus-basic-auth"
       "nginx.ingress.kubernetes.io/auth-realm" = "Authentication Required"
    }
  }

  spec {
    backend {
      service_name = "tf-es"
      service_port = 80
    }
    tls {
      hosts = [ "es.${var.dns_zone}" ]
      secret_name = "es-tls"
    }

    rule {
      host = "es.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-elasticsearch-elasticsearch-data"
            service_port = 9300
          }
          path = "/"
        }
      }
    }
  }
}

