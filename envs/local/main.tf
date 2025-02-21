module "metallb" {
  source = "../../modules/metallb"
}

module "cert_manager" {
  source = "../../modules/cert-manager"
}

module "cluster_issuer_selfsigned" {
  source = "../../modules/cluster-issuer-selfsigned"
  depends_on = [
    module.cert_manager
  ]
}

module "cluster_issuer_production" {
  source = "../../modules/cluster-issuer-production"
  depends_on = [
    module.cert_manager
  ]
}

module "ingress_nginx" {
  source = "../../modules/ingress-nginx"
  depends_on = [
    module.metallb,
    module.cluster_issuer_selfsigned,
    module.cluster_issuer_production
  ]
}

module "grafana" {
  source      = "../../modules/grafana"
  name        = var.grafana_name
  namespace   = var.grafana_namespace
  issuer_name = module.cluster_issuer_selfsigned.cluster_issuer_name
  depends_on = [
    module.ingress_nginx
  ]
}
