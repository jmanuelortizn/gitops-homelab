terraform {
  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
        # Approach B only — remove this block if using Approach A
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "~> 6.0"

    }
  }


}
