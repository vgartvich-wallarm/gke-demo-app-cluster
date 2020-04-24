resource "kubernetes_deployment" "mutillidae" {
  metadata {
    name = "tf-mutillidae"
    labels = {
      app = "tf-mutillidae"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tf-mutillidae"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-mutillidae"
        }
      }

      spec {
        container {
          name  = "mutillidae"
          image = "vgartvichwallarm/mutillidae:latest"

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

resource "kubernetes_service" "tf-mutillidae" {
  metadata {
    name = "tf-mutillidae"
  }
  spec {
    selector = {
      app = "tf-mutillidae"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "mutillidae" {
  metadata {
    name = "tf-mutillidae"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "$wallarm_mode_real"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "10"
    }
  }

  spec {
    backend {
      service_name = "tf-mutillidae"
      service_port = 80
    }

    rule {
      host = "mutillidae.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-mutillidae"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
