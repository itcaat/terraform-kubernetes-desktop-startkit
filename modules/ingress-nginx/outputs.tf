output "namespace" {
  description = "Ingress namespace"
  value       = helm_release.ingress_nginx.namespace
}
