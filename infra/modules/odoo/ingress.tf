resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "odoo-ingress"
    namespace = kubernetes_namespace_v1.env.metadata[0].name # <--- IMPORTANTE
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["odoo.${var.env_name}.${var.client_name}.local"]
      secret_name = kubernetes_secret_v1.tls.metadata[0].name
    }
    rule {
      host = "odoo.${var.env_name}.${var.client_name}.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.odoo.metadata[0].name
              port { number = 8069 }
            }
          }
        }
      }
    }
  }
}