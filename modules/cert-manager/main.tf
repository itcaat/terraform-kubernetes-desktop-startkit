resource "helm_release" "cert_manager" {
  name       = var.name
  repository = var.chart_repository
  chart      = var.chart_name
  namespace  = var.namespace
  version    = var.chart_version
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_secret" "mkcert_ca" {
  metadata {
    name      = var.mkcert_ca_secret_name
    namespace = var.namespace
  }

  data = {
    "tls.crt" = file("${var.mkcert_ca_cert_path}")
    "tls.key" = file("${var.mkcert_ca_key_path}")
  }

  type = "kubernetes.io/tls"

  depends_on = [helm_release.cert_manager]

}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${var.cluster_issuer_name}
  namespace: ${var.namespace}
spec:
  ca:
    secretName: ${var.mkcert_ca_secret_name}
YAML

  depends_on = [
    helm_release.cert_manager,
    kubernetes_secret.mkcert_ca
  ]
}
