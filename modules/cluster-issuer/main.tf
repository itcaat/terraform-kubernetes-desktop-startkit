resource "kubernetes_secret" "ca" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  data = {
    "tls.crt" = file("${var.ca_cert_path}")
    "tls.key" = file("${var.ca_key_path}")
  }

  type = "kubernetes.io/tls"
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
    secretName: ${var.name}
YAML

  depends_on = [
    kubernetes_secret.ca
  ]
}
