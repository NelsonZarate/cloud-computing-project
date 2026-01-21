resource "kubernetes_service_v1" "db" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.env.metadata[0].name # <--- IMPORTANTE
  }
  spec {
    selector = { app = "postgres" }
    port {
      port        = 5432
      target_port = 5432
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_stateful_set_v1" "db" {
  metadata {
    name      = "postgres-db"
    namespace = kubernetes_namespace_v1.env.metadata[0].name # <--- IMPORTANTE
  }
  spec {
    service_name = "postgres"
    replicas     = 1
    selector { match_labels = { app = "postgres" } }
    template {
      metadata { labels = { app = "postgres" } }
      spec {
        container {
          name  = "postgres"
          image = "postgres:15"
          env { 
            name = "POSTGRES_DB"
            value = "postgres" 
            }
          env { 
            name = "POSTGRES_USER"
            value = "odoo" 
            }

          env { 
            name = "POSTGRES_PASSWORD"
            value = "myodoo" 
            }
          resources {
            limits = { memory = "256Mi" }
            requests = { memory = "128Mi" }
          }
          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata { name = "postgres-data" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources { requests = { storage = "1Gi" } }
      }
    }
  }
}