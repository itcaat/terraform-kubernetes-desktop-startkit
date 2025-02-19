resource "helm_release" "ingress_nginx" {
  name             = var.name
  repository       = var.chart_repository
  chart            = var.chart_name
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = true
}
