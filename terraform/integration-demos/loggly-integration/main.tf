
resource "helm_release" "loggly-integration-tiredful-api" {
  name  = "tf-loggly-integration-tiredful-api"
  chart = "loggly-integration"

  set_string {
    name  = "pool_id"
    value = 9
  }

  set_string {
    name  = "schedule"
    value = "20 * * * *"
  }

  set_string {
    name  = "wallarm_api"
    value = var.api_host
  }

  set_string {
    name  = "image"
    value = "vgartvichwallarm/wallarm-api-examples"
  }

  set_sensitive {
    name  = "wallarm_uuid"
    value = var.wallarm_api_uuid
  }

  set_sensitive {
    name  = "wallarm_secret"
    value = var.wallarm_api_secret
  }

  set_sensitive {
    name  = "collector_address"
    value = var.loggly_collector_address
  }

}
