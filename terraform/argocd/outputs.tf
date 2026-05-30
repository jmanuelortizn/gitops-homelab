output "argocd_namespace" {
  value = var.argocd_namespace
}

output "argocd_helm_chart_version" {
  value = helm_release.argocd.version
}

output "argocd_service_type" {
  value = var.argocd_server_service_type
}

output "environment" {
  value = var.environment
}
