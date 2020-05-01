resource "kubernetes_deployment" "web-grpc" {
  metadata {
    name = "tf-web-grpc"
    labels = {
      app = "tf-web-grpc"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tf-web-grpc"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-web-grpc"
        }
      }

      spec {
        container {
          name  = "web-grpc-node"
          image = "vgartvichwallarm/grpc-server"
          port {
            name           = "grpc"
            container_port = 9090
            protocol       = "TCP"
          }
        }

        container {
          name  = "web-grpc-envoy"
          image = "wallarm/envoy"
          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          volume_mount {
            name       = "envoy-config"
            mount_path = "/etc/envoy/"
          }

          env {
            name  = "WALLARM_API_HOST"
            value = var.api_host
          }

          env {
            name = "DEPLOY_USER"

            value_from {
              secret_key_ref {
                key  = "DEPLOY_USER"
                name = "tf-wallarm-envoy-secret"
              }
            }
          }

          env {
            name = "DEPLOY_PASSWORD"

            value_from {
              secret_key_ref {
                key  = "DEPLOY_PASSWORD"
                name = "tf-wallarm-envoy-secret"
              }
            }
          }

        }
        container {
          name  = "web-grpc-client"
          image = "vgartvichwallarm/grpc-web"
          port {
            name           = "http"
            container_port = 8081
            protocol       = "TCP"
          }
        }

        volume {
          name = "envoy-config"
          config_map {
            name = "tf-wallarm-envoy-conf"
            items {
              key  = "envoy.yaml"
              path = "envoy.yaml"
            }
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "tf-web-grpc" {
  metadata {
    name = "tf-web-grpc"
  }
  spec {
    selector = {
      app = "tf-web-grpc"
    }
    port {
      name        = "front-http"
      port        = 80
      target_port = 8081
    }
    port {
      name        = "back-http"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_config_map" "tf-wallarm-envoy-conf" {
  metadata {
    name = "tf-wallarm-envoy-conf"
  }
  data = {
    "envoy.yaml" = "${file("${path.module}/envoy.yaml")}"
  }
}

resource "kubernetes_secret" "tf-wallarm-envoy-secret" {
  metadata {
    name = "tf-wallarm-envoy-secret"
  }

  data = {
    DEPLOY_USER     = var.waf_node_deploy_username
    DEPLOY_PASSWORD = var.waf_node_deploy_password
  }
  type = "Opaque"
}


resource "kubernetes_ingress" "tf-web-ingress" {
  metadata {
    name = "tf-web-grpc-ingress"
    annotations = {
      # "kubernetes.io/ingress.class"                  = "wallarm-ingress"
    }
  }

  spec {
    rule {
      host = "grpc.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-web-grpc"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_ingress" "tf-grpc-ingress" {
  metadata {
    name = "tf-web-grpc-ingress"
    annotations = {
      # "kubernetes.io/ingress.class"                  = "wallarm-ingress"
    }
  }

  spec {
    rule {
      host = "grpc.${var.dns_zone}"
      http {
        path {
          backend {
            service_name = "tf-web-grpc"
            service_port = 8080
          }
          path = "/"
        }
      }
    }
  }
}
