
variable "credentials" {
  type        = string
  description = "Location of the credentials keyfile."
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in."
}

variable "region" {
  type        = string
  description = "The region to host the cluster in."
}

variable "zone" {
  type        = string
  description = "The zone to host the cluster in."
}

variable "machine_type" {
  type        = string
  description = "Type of the Kubernetes node compute engines."
  default     = "n1-standard-2"
}

variable "waf_node_machine_type" {
  type        = string
  description = "Type of the standalone autoscaling WAF cluster node compute engines."
  default     = "n1-standard-1"
}

variable "splunk_machine_type" {
  type        = string
  description = "Type of the standalone Splunk server."
  default     = "n1-standard-1"
}

variable "min_count" {
  type        = number
  description = "Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count."
  default     = "1"
}

variable "max_count" {
  type        = number
  description = "Maximum number of nodes in the NodePool. Must be >= min_node_count."
  default     = "3"
}

variable "disk_size_gb" {
  type        = number
  description = "Size of the node's disk."
  default     = "30"
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default     = "1"
}

variable "dns_zone" {
  type        = string
  description = "The DNS zone which will be hosted in the GCP project and managed automatically using external-dns K8s service."
}

variable "suitecrm_username" {
  type        = string
  description = "The admin username to be configured for SuiteCRM app."
}

variable "suitecrm_password" {
  type        = string
  description = "The admin password to be configured for SuiteCRM app."
}

variable "prometheus_username" {
  type        = string
  description = "The username for Prometheus console UI."
}

variable "prometheus_encrypted_password" {
  type        = string
  description = "The encrypted password for Prometheus console UI."
}

variable "grafana_password" {
  type        = string
  description = "The admin password to be configured for Grafana console."
}

variable "ingress_controller_token" {
  type        = string
  description = "The Wallarm cloud node token to be used for the ingress controller."
}

variable "api_host" {
  type        = string
  default     = "us1.api.wallarm.com"
  description = "The Wallarm API end-point to the used by the ingress controller and other WAF nodes."
}

variable "acme_email" {
  type        = string
  description = "The email address to be used for automatic ACME registration."
}

variable "wordpress_username" {
  type        = string
  description = "Wordpress admin username"
}

variable "wordpress_password" {
  type        = string
  description = "Wordpress admin username"
}

variable "waf_node_deploy_username" {
  type        = string
  description = "The user with the Deploy permissions"
}

variable "waf_node_deploy_password" {
  type        = string
  description = "The password for the user with Deploy permissions"
}

variable "waf_node_acl_enabled" {
  type        = string
  description = "The variable defines IP ACL usage in a Wallarm container"
  default     = "False"
}

variable "waf_node_tarantool_memory" {
  type        = number
  description = "Amount of memory in GB for request analytics data, recommended value is 75% of the total server memory"
  default     = 0.2
}

variable "wallarm_api_uuid" {
  type        = string
  description = "Wallarm API UUID"
}

variable "wallarm_api_secret" {
  type        = string
  description = "Wallarm API secret"
}

variable "loggly_collector_address" {
  type        = string
  description = "Loggly collector URL for the HTTP receiver"
}

variable "ssh_username" {
  type        = string
  description = "The admin username to be created on newly provisioned Linux servers"
  default     = "admin"
}

variable "ssh_pub_key_file" {
  type        = string
  description = "The location of local SSH public keys file"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_file" {
  type        = string
  description = "The location of local SSH private keys file"
  default     = "~/.ssh/id_rsa"
}

variable "wallarm_gcp_node_image" {
  type        = string
  description = "The Wallarm node GCP image"
  default     = "wallarm-node-195710/wallarm-node-3-0-20210628-090819"
}

variable "wallarm_client_id" {
  type        = number
  description = "Wallarm customer account ID defined by tenant"
}

variable "gcp_gke_version" {
  type        = string
  description = "The min version of GKE masters"
  default     = "1.16.13-gke.401"
}
