variable "name" {
  type    = string
  default = "ingress-nginx"
}

variable "chart_repository" {
  type    = string
  default = "https://kubernetes.github.io/ingress-nginx"
}

variable "chart_name" {
  type    = string
  default = "ingress-nginx"
}

variable "chart_version" {
  type    = string
  default = "4.12.0"
}

variable "namespace" {
  type    = string
  default = "ingress-nginx"
}
