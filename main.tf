module "metallb" {
  source = "./modules/metallb"
}

module "cert_manager" {
  source = "./modules/cert-manager"
}

module "ingress_nginx" {
  source = "./modules/ingress-nginx"
  depends_on = [
    module.metallb,
    module.cert_manager
  ]
}

module "grafana" {
  source      = "./modules/grafana"
  issuer_name = module.cert_manager.cluster_issuer_name
}