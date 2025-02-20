module "metallb" {
  source = "../../modules/metallb"
}

module "cert_manager" {
  source = "../../modules/cert-manager"
}

module "cluster_issuer" {
  source = "../../modules/cluster-issuer"
  depends_on = [
    module.cert_manager
  ]
}

module "ingress_nginx" {
  source = "../../modules/ingress-nginx"
  depends_on = [
    module.metallb,
    module.cluster_issuer
  ]
}

module "grafana" {
  source      = "../../modules/grafana"
  name        = var.grafana_name
  namespace   = var.grafana_namespace
  issuer_name = module.cluster_issuer.cluster_issuer_name
  depends_on = [
    module.ingress_nginx
  ]
}
