resource "kubernetes_deployment" "tf-dvws" {
  metadata {
    name = "tf-dvws"
  }

  spec {
    selector {
      match_labels = {
        app = "tf-dvws"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-dvws"
        }
      }

      spec {
        volume {
          name = "wallarm-nginx-conf"

          config_map {
            name = "tf-wallarm-sidecar-nginx-conf"

            items {
              key  = "default"
              path = "default"
            }
          }
        }

        container {
          name    = "wallarm-nginx"
          image   = "awallarm/wallarm-node-sidecar:slim"
          command = ["/usr/local/bin/nginx.sh"]

          port {
            name           = "http"
            container_port = 56245
          }

          port {
            name           = "ws"
            container_port = 56246
          }

          env {
            name  = "WALLARM_API_HOST"
            value = "api.wallarm.com"
          }

          env {
            name = "WALLARM_API_TOKEN"

            value_from {
              secret_key_ref {
                name = "tf-wallarm-node-secret"
                key  = "WALLARM_API_TOKEN"
              }
            }
          }

          volume_mount {
            name       = "wallarm-nginx-conf"
            read_only  = true
            mount_path = "/etc/nginx/sites-enabled"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "56245"
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "56245"
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          image_pull_policy = "Always"
        }

        container {
          name    = "wallarm-tarantool"
          image   = "awallarm/wallarm-node-sidecar:slim"
          command = ["/usr/local/bin/tarantool.sh"]

          port {
            name           = "tcp"
            container_port = 3313
          }

          env {
            name  = "WALLARM_API_HOST"
            value = "api.wallarm.com"
          }

          env {
            name = "WALLARM_API_TOKEN"

            value_from {
              secret_key_ref {
                name = "tf-wallarm-node-secret"
                key  = "WALLARM_API_TOKEN"
              }
            }
          }

          resources {
            limits {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            tcp_socket {
              port = "3313"
            }

            initial_delay_seconds = 10
            period_seconds        = 20
          }

          readiness_probe {
            tcp_socket {
              port = "3313"
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        container {
          name  = "dvws"
          image = "tssoffsec/dvws"

          port {
            name           = "http"
            container_port = 80
          }

          port {
            name           = "ws"
            container_port = 8080
          }

          resources {
            limits {
              cpu    = "500m"
              memory = "128Mi"
            }
          }

          image_pull_policy = "IfNotPresent"
        }
      }
    }
  }
}

resource "kubernetes_service" "tf-dvws" {
  metadata {
    name = "tf-dvws"
  }

  spec {
    port {
      name        = "web-http"
      port        = 80
      target_port = "56245"
    }

    port {
      name        = "web-ws"
      port        = 8080
      target_port = "56246"
    }

    selector = {
      app = "tf-dvws"
    }
  }
}

resource "kubernetes_config_map" "tf-wallarm_sidecar_nginx_conf" {
  metadata {
    name = "tf-wallarm-sidecar-nginx-conf"
  }

  data = {
    default = "${file("${path.module}/default")}"
  }
}

resource "kubernetes_secret" "tf-wallarm-node-secret" {
  metadata {
    name = "tf-wallarm-node-secret"
  }

  data = {
    WALLARM_API_TOKEN = var.ingress_controller_token
  }
  type = "Opaque"
}


resource "kubernetes_ingress" "tf-dvws-web-ingress" {
  metadata {
    name = "tf-dvws-ingress"
    annotations = {
      # "kubernetes.io/ingress.class"                  = "wallarm-ingress"
    }
  }

  spec {
    rule {
      host = "dvws.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-dvws"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_ingress" "tf-dvws-ws-ingress" {
  metadata {
    name = "tf-dvws-ingress"
    annotations = {
      # "kubernetes.io/ingress.class"                  = "wallarm-ingress"
    }
  }

  spec {
    rule {
      host = "dvws.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-dvws"
            service_port = 8080
          }
          path = "/"
        }
      }
    }
  }
}
