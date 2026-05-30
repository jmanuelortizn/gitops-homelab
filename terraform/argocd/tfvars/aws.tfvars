environment        = "aws"
argocd_version     = "6.7.3"
argocd_namespace   = "argocd"
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:us-east-1:<your-account-id>:cluster/ml-serving-cluster"

gitops_repo_url      = "https://github.com/jmanuelortizn/gitops-homelab.git"
gitops_repo_username = "jmanuelortizn"

argocd_server_service_type = "LoadBalancer"
argocd_ingress_enabled     = true
argocd_ingress_host        = "argocd.<your-domain>.com"
argocd_ingress_cert_arn    = "arn:aws:acm:us-east-1:<account>:certificate/<cert-id>"

# Sensitive vars set via TF_VAR environment variables — not here
