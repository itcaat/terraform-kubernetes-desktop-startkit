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
