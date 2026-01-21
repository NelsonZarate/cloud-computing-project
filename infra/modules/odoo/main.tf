resource "kubernetes_namespace_v1" "env" {
  metadata {
    name = "${var.client_name}-${var.env_name}"
  }
}