
resource "helm_release" "external-dns" {
  name  = "tf-external-dns"
  chart = "external-dns"

  set_string {
    name  = "provider"
    value = "google"
  }
  set_string {
    name  = "google.project"
    value = var.project_id
  }

  set_string {
    name  = "domainFilters.0"
    value = var.dns_zone
  }

  set_sensitive {
    name  = "google.serviceAccountKey"
    value = filebase64(var.credentials)
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "metrics.serviceMonitor.enabled"
    value = "true"
  }

  set_string {
    name  = "metrics.podAnnotations.prometheus\\.io/scrape"
    value = "true"
  }

  set_string {
    name  = "metrics.podAnnotations.prometheus\\.io/port"
    value = "7979"
  }
}
