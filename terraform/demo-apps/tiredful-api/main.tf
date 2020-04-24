
resource "kubernetes_deployment" "tiredful-api" {
  metadata {
    name = "tf-tiredful-api"
    labels = {
      app = "tf-tiredful-api"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tf-tiredful-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-tiredful-api"
        }
      }

      spec {
        container {
          image = "vgartvichwallarm/tiredfulapi:latest"
          name  = "tiredful-api"

          resources {
            limits {
              memory = "256Mi"
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

resource "kubernetes_service" "tf-tiredful-api" {
  metadata {
    name = "tf-tiredful-api"
  }
  spec {
    selector = {
      app = "tf-tiredful-api"
    }
    port {
      port        = 80
      target_port = 8000
    }
  }
}

resource "kubernetes_ingress" "tiredful-api" {
  metadata {
    name = "tf-tiredful-api"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "$wallarm_mode_real"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "9"
    }
  }

  spec {
    backend {
      service_name = "tf-tiredful-api"
      service_port = 80
    }

    rule {
      host = "tiredful-api.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-tiredful-api"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
