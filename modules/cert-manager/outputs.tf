output "namespace" {
  description = "Cert Manager namespace"
  value       = helm_release.cert_manager.namespace
}
