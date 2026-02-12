module "metallb" {
  source   = "../../modules/metallb"
  ip_range = local.metallb_ip_range
}

module "cert_manager" {
  source = "../../modules/cert-manager"
}

module "cluster_issuer_selfsigned" {
  source  = "../../modules/cluster-issuer-selfsigned"
  name    = local.cluster_issuer_selfsigned
  ca_cert = var.cluster_issuer_selfsigned_ca_cert
  ca_key  = var.cluster_issuer_selfsigned_ca_key
  depends_on = [
    module.cert_manager
  ]
}

module "cluster_issuer_production" {
  source     = "../../modules/cluster-issuer-production"
  name       = local.cluster_issuer_production
  acme_email = local.cluster_issuer_production_acme_email
  depends_on = [
    module.cert_manager
  ]
}

module "ingress_nginx" {
  source     = "../../modules/ingress-nginx"
  class_name = local.ingress_class_name
  depends_on = [
    module.metallb
  ]
}

module "echo_server" {
  source             = "../../modules/echo-server"
  hostname           = "echo.${local.root_domain}"
  namespace          = "demo"
  replicas           = 1
  ingress_class_name = local.ingress_class_name
  issuer_name        = local.cluster_issuer_selfsigned
  depends_on = [
    module.ingress_nginx,
    module.cluster_issuer_selfsigned
  ]
}
