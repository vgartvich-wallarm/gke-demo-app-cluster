
resource "helm_release" "wallarm-ingress" {
  name  = "tf-wallarm-ingress"
  chart = "wallarm-ingress"

  set {
    name  = "controller.wallarm.enabled"
    value = "true"
  }

  set_sensitive {
    name = "controller.wallarm.token"
    value = var.ingress_controller_token
  }

  set_string {
    name = "controller.wallarm.apiHost"
    value = var.api_host
  }

  set {
    name = "controller.wallarm.acl.enabled"
    value = "true"
  }

  set_string {
    name = "controller.ingressClass"
    value = "wallarm-ingress"
  }

  set_string {
    name = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name = "controller.publishService.enabled"
    value = "true"
  }

  set_string {
    name = "controller.config.server-snippet"
    value = "set_real_ip_from 10.0.0.0/8;"
  }

  set_string {
    name = "controller.config.use-forwarded-headers"
    value = "true"
  }

  set_string {
    name = "controller.config.http-snippet"
    value = file("whitelist.yaml")
  }
}
