output "cluster_issuer_name" {
  description = "The name of the ClusterIssuer"
  value       = kubectl_manifest.cluster_issuer.name
}
