
resource "helm_release" "fluentd" {
  name  = "tf-fluentd"
  chart = "fluentd"

  set_string {
    name = "aggregator.configMap"
    value = "tf-fluentd"
  }

  set_string {
    name = "aggregator.extraEnv[0].name"
    value = "ELASTICSEARCH_HOST"
  }

  set_string {
    name = "aggregator.extraEnv[0].value"
    value = "tf-elasticsearch-elasticsearch-data"
  }

  set_string {
    name = "aggregator.extraEnv[1].name"
    value = "ELASTICSEARCH_PORT"
  }

  set_string {
    name = "aggregator.extraEnv[1].value"
    value = "9300"
  }

  set {
    name = "metrics.enabled"
    value = "true"
  }

  set {
    name = "metrics.serviceMonitor.enabled"
    value = "true"
  }
}

resource "kubernetes_config_map" "fluentd" {
  metadata {
    name = "tf-fluentd"
  }

  data = {
    "fluentd.conf" = file("fluentd.conf")
  }
}
