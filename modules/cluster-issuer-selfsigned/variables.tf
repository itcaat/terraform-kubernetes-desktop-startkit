variable "secret_name" {
  type        = string
  description = "The name of the ClusterIssuer for selfsigned CA"
  default     = "ca-key-pair-selfsigned"
}

variable "namespace" {
  type    = string
  default = "cert-manager"
}

variable "ca_cert_path" {
  type        = string
  description = "Path to mkcert CA certificate"
  default     = "~/Library/Application Support/mkcert/rootCA.pem"
}

variable "ca_key_path" {
  type        = string
  description = "Path to mkcert CA key"
  default     = "~/Library/Application Support/mkcert/rootCA-key.pem"
}

variable "cluster_issuer_name" {
  type        = string
  description = "The name of the ClusterIssuer"
  default     = "selfsigned"
}

