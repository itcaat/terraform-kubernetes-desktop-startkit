variable "name" {
  type    = string
  default = "metallb"
}

variable "chart_repository" {
  type    = string
  default = "https://metallb.github.io/metallb"
}

variable "chart_name" {
  type    = string
  default = "metallb"
}

variable "chart_version" {
  type    = string
  default = "0.14.9"
}

variable "ip_range" {
  type        = list(string)
  description = "IP Range for MetalLB"
  default     = ["127.0.0.1-127.0.0.1"]
}

variable "namespace" {
  type    = string
  default = "metallb-system"
}

