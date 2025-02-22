resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.namespace
  repository       = var.chart_repository
  chart            = var.chart_name
  version          = var.chart_version
  create_namespace = true

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.hostname"
    value = var.ingress_hostname
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = var.ingress_class
  }

  set {
    name  = "server.ingress.path"
    value = "/"
  }

  set {
    name  = "server.ingress.pathType"
    value = "Prefix"
  }

  set {
    name  = "server.ingress.tls"
    value = "true"
  }

  set {
    name  = "server.insecure"
    value = "true"
  }
}
