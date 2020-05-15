
resource "kubernetes_deployment" "httpbin" {
  metadata {
    name = "tf-httpbin"
    labels = {
      app = "tf-httpbin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tf-httpbin"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-httpbin"
        }
      }

      spec {
        container {
          image = "kennethreitz/httpbin"
          name  = "httpbin"
          image_pull_policy = "IfNotPresent"

          resources {
            limits {
              memory = "128Mi"
            }
            requests {
              cpu    = "50m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "tf-httpbin" {
  metadata {
    name = "tf-httpbin"
  }
  spec {
    selector = {
      app = "tf-httpbin"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "nginx" {
  metadata {
    name = "tf-httpbin"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "$wallarm_mode_real"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "1"
       "cert-manager.io/issuer" = "letsencrypt-prod"
       "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    backend {
      service_name = "tf-httpbin"
      service_port = 80
    }

    tls {
      hosts = [ "httpbin.${var.dns_zone}" ]
      secret_name = "httpbin-tls"
    }

    rule {
      host = "httpbin.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-httpbin"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
