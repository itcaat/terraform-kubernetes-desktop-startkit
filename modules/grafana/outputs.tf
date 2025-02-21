output "grafana_ingress_url" {
  description = "Grafana Url"
  value       = "https://${local.hostname}"
}
