variable "namespace" {
  type    = string
  default = "cert-manager"
}
variable "cluster_issuer_name" {
  type        = string
  description = "The name of the ClusterIssuer"
  default     = "letsencrypt"
}

variable "acme_email" {
  type        = string
  description = "Email used for ACME registration"
  default     = "admin@example.com"
}

variable "acme_server" {
  type        = string
  description = "ACME server URL (production or staging)"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "secret_name" {
  type        = string
  description = "Name of the Kubernetes secret for storing the ACME private key"
  default     = "letsencrypt-private-key"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class used for HTTP-01 Challenge"
  default     = "nginx"
}
