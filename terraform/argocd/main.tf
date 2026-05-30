provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
}

# The ArgoCD provider connects to the ArgoCD API after Helm installs it.
# port_forward_with_namespace handles the port-forward automatically during apply.
provider "argocd" {
  server_addr                 = "argocd.example.com:8443"
  username                    = "admin"
  password                    = var.argocd_admin_password_plain
  insecure                    = true
  #port_forward_with_namespace = var.argocd_namespace
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

resource "helm_release" "argocd" {
  name            = "argocd"
  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  version         = var.argocd_version
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  cleanup_on_fail = true
  wait            = true
  timeout         = 300

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password_bcrypt
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "server.service.type"
    value = var.argocd_server_service_type
  }

  values = [yamlencode(local.argocd_values)]

  depends_on = [kubernetes_namespace.argocd, helm_release.traefik]
}
resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "40.2.0"   # pin to avoid surprise upgrades
  namespace        = "kube-system"
  wait             = true
  wait_for_jobs    = true
  values = [yamlencode(local.traefik_values)]
}

resource "argocd_repository" "gitops_homelab" {
  repo     = var.gitops_repo_url
  username = var.gitops_repo_username
  password = var.gitops_repo_password
  insecure = false

  depends_on = [helm_release.argocd]
}

resource "argocd_project" "ml_infra" {
  metadata {
    name      = "ml-infra"
    namespace = var.argocd_namespace
  }

  spec {
    description = "ML Infrastructure projects (01-05)"

    source_repos = [
      var.gitops_repo_url,
      "https://github.com/*",
      "https://argoproj.github.io/argo-helm",
      "https://grafana.github.io/helm-charts",
      "https://prometheus-community.github.io/helm-charts",
      "https://charts.bitnami.com/bitnami",
      "https://kedacore.github.io/charts",
      "https://downloads.apache.org/flink/*",
    ]

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "project-*"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "observability"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }
  }

  depends_on = [helm_release.argocd]
}

resource "argocd_application" "app_of_apps" {
  metadata {
    name       = "app-of-apps"
    namespace  = var.argocd_namespace
    ##finalizers = ["resources-finalizer.argocd.argoproj.io"]
  }

  spec {
    project = "ml-infra"

    source {
      repo_url        = var.gitops_repo_url
      target_revision = "HEAD"
      path            = "argocd/apps"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = var.argocd_namespace
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
      sync_options = ["CreateNamespace=true"]
    }
  }

  depends_on = [argocd_repository.gitops_homelab, argocd_project.ml_infra]
}
