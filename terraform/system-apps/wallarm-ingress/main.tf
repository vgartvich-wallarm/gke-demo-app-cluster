
resource "helm_release" "wallarm-ingress" {
  name  = "tf-wallarm-ingress"
  chart = "ingress-chart-2.18.1/ingress-chart/wallarm-ingress"
  force_update = true

  set {
    name  = "controller.wallarm.enabled"
    value = "true"
  }

  set_string {
    name  = "controller.resources.requests.cpu"
    value = "30m"
  }

  set_string {
    name  = "controller.wallarm.tarantool.resources.requests.cpu"
    value = "10m"
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
    value = "set_real_ip_from 10.0.0.0/8; wallarm_enable_libdetection on; proxy_request_buffering on;"
  }

  set_string {
    name = "controller.config.use-forwarded-headers"
    value = "true"
  }

  set {
    name = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name = "controller.stats.enabled"
    value = "true"
  }

  set_string {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = "true"
  }

  set_string {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = "10254"
  }

  set {
    name = "controller.wallarm.metrics.enabled"
    value = "true"
  }

  set {
    name = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }

  set_string {
    name  = "controller.wallarm.metrics.service.annotations.prometheus\\.io/scrape"
    value = "true"
  }

  set_string {
    name  = "controller.wallarm.metrics.service.annotations.prometheus\\.io/path"
    value = "/wallarm-metrics"
  }

  set_string {
    name  = "controller.wallarm.metrics.service.annotations.prometheus\\.io/port"
    value = "18080"
  }

  set_string {
    name = "controller.config.http-snippet"
    value = file("whitelist.yaml")
  }
}
