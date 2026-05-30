variable "environment" {
  description = "Deployment environment: homelab or aws"
  type        = string
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version (argo-cd chart, not ArgoCD app version)"
  type        = string
  default     = "6.7.3"
}

variable "argocd_namespace" {
  description = "Namespace to install ArgoCD into"
  type        = string
  default     = "argocd"
}

variable "argocd_admin_password_bcrypt" {
  description = "bcrypt hash of the ArgoCD admin password"
  type        = string
  sensitive   = true
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context name to use"
  type        = string
}

variable "gitops_repo_url" {
  description = "HTTPS URL of the gitops-homelab GitHub repository"
  type        = string
}

variable "gitops_repo_username" {
  description = "GitHub username for GitOps repo access"
  type        = string
}

variable "gitops_repo_password" {
  description = "GitHub Personal Access Token for GitOps repo access"
  type        = string
  sensitive   = true
}

variable "argocd_server_service_type" {
  description = "ClusterIP for homelab, LoadBalancer for EKS"
  type        = string
  default     = "ClusterIP"
}

variable "argocd_ingress_enabled" {
  description = "Enable ALB ingress (EKS only)"
  type        = bool
  default     = false
}

variable "argocd_ingress_host" {
  description = "Hostname for ArgoCD ALB ingress (EKS only)"
  type        = string
  default     = ""
}

variable "argocd_ingress_cert_arn" {
  description = "ACM certificate ARN for HTTPS (EKS only)"
  type        = string
  default     = ""
}

variable "argocd_admin_password_plain" {
  description = "Plain text admin password for ArgoCD"
  type        = string
  sensitive   = true
}
variable "port_forward_with_namespace" {
  description = "bcrypt hash of the ArgoCD admin password"
  type        = string
  sensitive   = true
}
variable "ingress_class_name" {
  description = "Ingress class name to use for ArgoCD server ingress"
  type        = string
  default     = "traefik"
}