resource "helm_release" "metallb" {
  name             = var.name
  repository       = var.chart_repository
  chart            = var.chart_name
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = true
}

resource "kubectl_manifest" "metallb_ip_pool" {
  yaml_body = <<YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ingress-ip-pool
  namespace: ${var.namespace}
spec:
  addresses:
    %{for ip in var.metallb_ip_range~}
    - ${ip}
    %{endfor~}
YAML

  depends_on = [helm_release.metallb]
}

resource "kubectl_manifest" "metallb_l2_advertisement" {
  yaml_body = <<YAML
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: advert
  namespace: ${var.namespace}
YAML

  depends_on = [kubectl_manifest.metallb_ip_pool]
}
