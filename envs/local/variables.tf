variable "kube_config_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "docker-desktop"
}

variable "echo_namespace" {
  description = "Echo Server Namespace"
  type        = string
  default     = "demo"
}

variable "echo_name" {
  description = "Echo Server Name. Will be used in hostname"
  type        = string
  default     = "echo"
}

variable "echo_replicas" {
  description = "Echo Server replicas"
  type        = number
  default     = 1
}

variable "metallb_ip_range" {
  type        = list(string)
  description = "IP Range for MetalLB"
  default     = ["127.0.0.1-127.0.0.1"]
}

variable "cluster_issuer_selfsigned_ca_cert_path" {
  type        = string
  description = "Path to selfsigned CA certificate"
}

variable "cluster_issuer_selfsigned_ca_key_path" {
  type        = string
  description = "Path to selfsigned CA key"
}

variable "cluster_issuer_production_acme_email" {
  type        = string
  description = "Email used for ACME registration"
  default     = "admin@example.com"
}
