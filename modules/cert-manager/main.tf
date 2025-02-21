resource "helm_release" "cert_manager" {
  name             = var.name
  repository       = var.chart_repository
  chart            = var.chart_name
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}
