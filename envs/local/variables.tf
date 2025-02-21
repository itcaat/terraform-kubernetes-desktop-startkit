variable "kube_config_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "docker-desktop"
}

variable "grafana_namespace" {
  description = "Grafana Namespace"
  type        = string
  default     = "grafana"
}

variable "grafana_name" {
  description = "Grafana Name. Will be used as hostname"
  type        = string
  default     = "grafana"
}
