
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "tf-nginx"
    labels = {
      app = "tf-nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tf-nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-nginx"
        }
      }

      spec {
        container {
          image = "vgartvichwallarm/vulnerablenginx:latest"
          name  = "nginx"
          image_pull_policy = "Always"

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

resource "kubernetes_service" "tf-nginx" {
  metadata {
    name = "tf-nginx"
  }
  spec {
    selector = {
      app = "tf-nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "nginx" {
  metadata {
    name = "tf-nginx"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "$wallarm_mode_real"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "1"
       "nginx.ingress.kubernetes.io/configuration-snippet" = "more_set_input_headers 'VICTORTEST $remote_addr';"
    }
  }

  spec {
    backend {
      service_name = "tf-nginx"
      service_port = 80
    }

    rule {
      host = "nginx.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-nginx"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
