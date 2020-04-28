
resource "kubernetes_deployment" "echo-server" {
  metadata {
    name = "tf-echo-server"
    labels = {
      app = "tf-echo-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tf-echo-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-echo-server"
        }
      }

      spec {
        container {
          image = "gcr.io/google-containers/echoserver:1.10"
          name  = "echo-server"
          args = ["--port=8080", "--expose" ]

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

resource "kubernetes_service" "tf-echo-server" {
  metadata {
    name = "tf-echo-server"
  }
  spec {
    selector = {
      app = "tf-echo-server"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress" "echo-server" {
  metadata {
    name = "tf-echo-server"
    annotations = {
       "kubernetes.io/ingress.class" = "wallarm-ingress"
       "nginx.ingress.kubernetes.io/wallarm-mode" = "$wallarm_mode_real"
       "nginx.ingress.kubernetes.io/wallarm-acl" = "on"
       "nginx.ingress.kubernetes.io/wallarm-instance" = "8"
       "nginx.ingress.kubernetes.io/proxy-body-size" = "500m"
       "cert-manager.io/issuer" = "letsencrypt-prod"
    }
  }

  spec {
    backend {
      service_name = "tf-echo-server"
      service_port = 80
    }
    tls {
      hosts = [ "echo-server.${var.dns_zone}" ]
      secret_name = "echo-server-tls"
    }

    rule {
      host = "echo-server.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-echo-server"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
