provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config_path
    config_context = var.kube_context
  }
}

provider "kubectl" {
  config_path    = var.kube_config_path
  config_context = var.kube_context
}
