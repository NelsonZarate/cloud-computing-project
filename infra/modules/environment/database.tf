# 1. Service para o Postgres (Permite que o Odoo encontre o DB)
resource "kubernetes_service_v1" "postgres" {
  metadata {
    name = "mydb" # O nome que usaremos no host do Odoo
    # namespace = "client-env" (Isso será dinâmico depois)
  }

  spec {
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    cluster_ip = "None"
  }
}

# 2. StatefulSet do Postgres
resource "kubernetes_stateful_set_v1" "postgres" {
  metadata {
    name = "postgres-db"
  }

  spec {
    service_name = kubernetes_service_v1.postgres.metadata[0].name
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15"

          env {
            name  = "POSTGRES_DB"
            value = "postgres"
          }
          env {
            name  = "POSTGRES_USER"
            value = "odoo"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "myodoo" # Em prod, usaremos kubernetes_secret
          }

          port {
            container_port = 5432
          }

          # Montagem do volume (definido abaixo)
          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }

    # Definição do PVC (Persistent Volume Claim)
    volume_claim_template {
      metadata {
        name = "postgres-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }
}