output "ingress_nginx_namespace" {
  description = "The name of the ClusterIssuer"
  value       = helm_release.cert_manager.namespace
}
