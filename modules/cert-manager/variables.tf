variable "name" {
  type    = string
  default = "cert-manager"
}

variable "namespace" {
  type    = string
  default = "cert-manager"
}

variable "chart_repository" {
  type    = string
  default = "https://charts.jetstack.io"
}

variable "chart_name" {
  type    = string
  default = "cert-manager"
}

variable "chart_version" {
  type    = string
  default = "1.17.1"
}

variable "mkcert_ca_cert_path" {
  type        = string
  description = "Path to mkcert CA certificate"
  default     = "~/Library/Application Support/mkcert/rootCA.pem"
}

variable "mkcert_ca_key_path" {
  type        = string
  description = "Path to mkcert CA key"
  default     = "~/Library/Application Support/mkcert/rootCA-key.pem"
}

variable "cluster_issuer_name" {
  type        = string
  description = "The name of the ClusterIssuer"
  default     = "mkcert-issuer"
}

variable "mkcert_ca_secret_name" {
  type        = string
  description = "The name of the ClusterIssuer"
  default     = "mkcert-ca-key-pair"
}
