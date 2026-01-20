resource "kubernetes_secret_v1" "postgres_password" {
  metadata {
    name = "postgresql-password"
  }

  data = {
    postgresql_password = "password"
  }

  type = "Opaque"
}
