variable "name" {
  type    = string
  default = "grafana"
}

variable "image_tag" {
  type    = string
  default = "0.9.2"
}

variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "replicas" {
  type    = number
  default = 1
}

variable "ingress_class_name" {
  type    = string
  default = "nginx"
}

variable "issuer_name" {
  type        = string
  description = "The name of the ClusterIssuer to use for TLS"
}

locals {
  hostname    = "${var.name}.127.0.0.1.nip.io"
  secret_name = "${var.name}-tls"
  image       = "ealen/echo-server:${var.image_tag}"
}
