resource "kubernetes_service_v1" "db" {
  metadata {
    name = "odoo-db"
  }

  spec {
    selector = {
      app = "odoo-db"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}
