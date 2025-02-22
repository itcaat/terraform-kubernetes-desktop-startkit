variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_repository" {
  type    = string
  default = "https://charts.bitnami.com/bitnami"
}

variable "chart_name" {
  type    = string
  default = "bitnami/argo-cd"
}

variable "chart_version" {
  type    = string
  default = "7.1.10"
}

variable "ingress_hostname" {
  type        = string
  description = "Hostname for ArgoCD Ingress"
  default     = "argocd.127.0.0.1.nip.io"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class for ArgoCD"
  default     = "nginx"
}
