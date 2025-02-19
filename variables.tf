variable "kube_config_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "grafana_replicas" {
  type    = number
  default = 1
}

variable "grafana_namespace" {
  type    = string
  default = "monitoring"
}

variable "kube_context" {
  type    = string
  default = "docker-desktop"
}
