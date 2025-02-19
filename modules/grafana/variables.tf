variable "name" {
  type    = string
  default = "grafana"
}

variable "image_tag" {
  type    = string
  default = "11.5.1"
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

variable "host" {
  type    = string
  default = "grafana.127.0.0.1.nip.io"
}

variable "issuer_name" {
  type        = string
  description = "The name of the ClusterIssuer to use for TLS"
}