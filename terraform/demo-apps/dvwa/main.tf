resource "kubernetes_deployment" "dvwa" {
  metadata {
    name = "tf-dvwa"
    labels = {
      app = "tf-dvwa"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tf-dvwa"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-dvwa"
        }
      }

      spec {
        container {
          name  = "dvwa"
          image = "vulnerables/web-dvwa"

          resources {
            limits {
              memory = "512Mi"
            }
            requests {
              cpu    = "100m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "tf-dvwa" {
  metadata {
    name = "tf-dvwa"
  }
  spec {
    selector = {
      app = "tf-dvwa"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "dvwa_ingress" {
  metadata {
    name = "tf-dvwa-ingress"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "$wallarm_mode_real"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "5"
    }
  }

  spec {
    backend {
      service_name = "tf-dvwa"
      service_port = 80
    }

    rule {
      host = "dvwa.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-dvwa"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
