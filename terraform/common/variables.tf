
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

variable "machine_type" {
  type        = string
  description = "Type of the node compute engines."
  default = "n1-standard-2"
}

variable "min_count" {
  type        = number
  description = "Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count."
  default = "1"
}

variable "max_count" {
  type        = number
  description = "Maximum number of nodes in the NodePool. Must be >= min_node_count."
  default = "5"
}

variable "disk_size_gb" {
  type        = number
  description = "Size of the node's disk."
  default = "10"
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default = "1"
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

variable "ingress_controller_token" {
  type        = string
  description = "The Wallarm cloud node token to be used for the ingress controller."
}

variable "api_host" {
  type        = string
  default     = "us1.api.wallarm.com"
  description = "The Wallarm API end-point to the used by the ingress controller and other WAF nodes."
}
