locals {
 traefik_values = {
    service = { type = "NodePort" }
    ports = {
      web = {
        nodePort = 30080
        # redirectTo changed to redirections in newer chart
        # redirections = {
        #   entryPoint = {
        #     to       = "websecure"
        #     scheme   = "https"
        #     permanent = true
        #   }
        #}
      }
      websecure = {
        nodePort = 30443
        # tls moved out of ports in newer chart
      }
    }

    # TLS is now configured here instead
    tlsStore = {
      default = {
        defaultGeneratedCert = {
          resolver = null
          domain = {
            main = "homelab.local"
            sans = ["*.homelab.local"]
          }
        }
      }
    }

    resources = {
      requests = { cpu = "50m",  memory = "64Mi"  }
      limits   = { cpu = "200m", memory = "128Mi" }
    }

    logs = {
      access  = { enabled = true }
      general = { level = "INFO" }
    }
  }

argocd_values = {
    global = {
      env = [{ name = "ENVIRONMENT", value = var.environment }]
    }

    configs = {
      params = {
        "server.insecure" = "true"  # TLS terminated at Traefik
      }

      # RBAC — still good practice even in homelab
      rbac = {
        "policy.default" = "role:readonly"
        "policy.csv"     = <<-EOT
          p, role:admin, applications, *, */*, allow
          p, role:admin, clusters, *, *, allow
          p, role:admin, repositories, *, *, allow
          p, role:admin, logs, get, *, allow
          p, role:admin, exec, create, */*, allow
          g, admin, role:admin
        EOT
      }

      # Secure the secret key
      secret = {
        argocdServerAdminPassword = bcrypt(var.argocd_admin_password_plain)
      }
    }

    controller = {
      resources = {
        requests = { cpu = "100m", memory = "256Mi" }
        limits   = { cpu = "500m", memory = "512Mi" }
      }
    }

    repoServer = {
      resources = {
        requests = { cpu = "50m",  memory = "128Mi" }
        limits   = { cpu = "200m", memory = "256Mi" }
      }
    }

    server = {
      resources = {
        requests = { cpu = "50m",  memory = "64Mi"  }
        limits   = { cpu = "200m", memory = "128Mi" }
      }

      ingress = {
        enabled          = true
        ingressClassName = "traefik"
        tls              = false  # Traefik handles TLS
        servicePort      = "http"
        annotations = {
          "traefik.ingress.kubernetes.io/router.entrypoints"    = "websecure"  # HTTPS only
          "traefik.ingress.kubernetes.io/service.serversscheme" = "http"
          "traefik.ingress.kubernetes.io/router.tls"            = "true"
        }
        hosts = [var.argocd_ingress_host]
      }
    }
  }
}