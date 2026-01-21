resource "kubernetes_service_v1" "odoo" {
  metadata {
    name      = "odoo"
    namespace = kubernetes_namespace_v1.env.metadata[0].name # <--- IMPORTANTE
  }
  spec {
    selector = { app = "odoo" }
    port {
      port        = 8069
      target_port = 8069
    }
  }
}

resource "kubernetes_deployment_v1" "odoo" {
  metadata {
    name      = "odoo-app"
    namespace = kubernetes_namespace_v1.env.metadata[0].name # <--- IMPORTANTE
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "odoo" } }
    template {
      metadata { labels = { app = "odoo" } }
      spec {
        container {
          name  = "odoo"
          image = "odoo:16.0"
          env { 
            name = "HOST"
            value = "postgres" 
           }
          env { 
            name = "USER"
            value = "odoo" 
            }
          env { 
            name = "PASSWORD"
            value = "myodoo" 
            }
          resources {
            limits = { memory = "512Mi" }
            requests = { memory = "256Mi" }
          }
        }
      }
    }
  }
}