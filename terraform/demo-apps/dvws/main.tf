resource "kubernetes_deployment" "tf-dvws" {
  metadata {
    name = "tf-dvws"
    labels = {
      app = "tf-dvws"
    }
  }

  spec {
    replicas = 1

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
          name  = "wallarm-nginx"
          image = "wallarm/node:2.14"

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
            value = var.api_host
          }

          env {
            name  = "WALLARM_ACL_ENABLE"
            value = var.waf_node_acl_enabled
          }

          env {
            name  = "TARANTOOL_MEMORY_GB"
            value = var.waf_node_tarantool_memory
          }

          env {
            name = "DEPLOY_USER"

            value_from {
              secret_key_ref {
                key  = "DEPLOY_USER"
                name = "tf-wallarm-node-secret"
              }
            }
          }

          env {
            name = "DEPLOY_PASSWORD"

            value_from {
              secret_key_ref {
                key  = "DEPLOY_PASSWORD"
                name = "tf-wallarm-node-secret"
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

resource "kubernetes_config_map" "tf-wallarm-sidecar-nginx-conf" {
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
    DEPLOY_USER     = var.waf_node_deploy_username
    DEPLOY_PASSWORD = var.waf_node_deploy_password
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
