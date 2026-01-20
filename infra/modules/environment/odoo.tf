# 1. Service do Odoo (Para expor a aplicação internamente)
resource "kubernetes_service_v1" "odoo" {
  metadata {
    name = "odoo-svc"
  }

  spec {
    selector = {
      app = "odoo"
    }
    port {
      port        = 8069
      target_port = 8069
    }
    type = "ClusterIP"
  }
}

# 2. Deployment do Odoo
resource "kubernetes_deployment_v1" "odoo" {
  metadata {
    name = "odoo-app"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "odoo"
      }
    }

    template {
      metadata {
        labels = {
          app = "odoo"
        }
      }

      spec {
        container {
          name  = "odoo"
          image = "odoo:17.0"

          # Configuração de conexão com o banco
          env {
            name  = "HOST"
            value = "mydb" # Deve bater com o nome do Service do Postgres acima
          }
          env {
            name  = "USER"
            value = "odoo"
          }
          env {
            name  = "PASSWORD"
            value = "myodoo"
          }

          port {
            container_port = 8069
          }
          
          # Health check básico (Recomendado)
          liveness_probe {
            http_get {
              path = "/"
              port = 8069
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}