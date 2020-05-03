
resource "helm_release" "log-integration-tiredful-api" {
  name  = "tf-log-integration-tiredful-api"
  chart = "log-integration"

  set_string {
    name  = "pool_id"
    value = 9
  }

  set_string {
    name  = "schedule"
    value = "0 * * * *"
  }

  set_string {
    name  = "wallarm_api"
    value = "us1.api.wallarm.com"
  }

  set_string {
    name  = "image"
    value = "awallarm/log-exporter:latest"
  }

  set_sensitive {
    name  = "wallarm_uuid"
    value = var.loggly_wallarm_uuid
  }

  set_sensitive {
    name  = "wallarm_secret"
    value = var.loggly_wallarm_secret
  }

  set_sensitive {
    name  = "collector_address"
    value = var.loggly_collector_address
  }

}
