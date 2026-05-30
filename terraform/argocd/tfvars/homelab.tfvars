environment                = "homelab"
argocd_version             = "6.7.3"
argocd_namespace           = "argocd"
kubeconfig_path            = "~/.kube/config"
kubeconfig_context         = "k3d-homelab"
gitops_repo_url            = "https://github.com/jmanuelortizn/gitops-homelab.git"
gitops_repo_username       = "jmanuelortizn"
argocd_server_service_type = "ClusterIP"
argocd_ingress_enabled     = true
port_forward_with_namespace = "argocd"
argocd_ingress_host        = "argocd.homelab.local"
# Sensitive vars set via TF_VAR environment variables — not here:
# export TF_VAR_argocd_admin_password_bcrypt="..."
# export TF_VAR_gitops_repo_password="..."
