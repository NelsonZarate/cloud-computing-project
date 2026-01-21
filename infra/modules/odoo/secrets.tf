resource "tls_private_key" "pk" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.pk.private_key_pem
  subject {
    common_name  = "odoo.${var.env_name}.${var.client_name}.local"
    organization = "${var.client_name} Corp"
  }
  validity_period_hours = 24
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "kubernetes_secret_v1" "tls" {
  metadata {
    name      = "odoo-tls-cert"
    namespace = kubernetes_namespace_v1.env.metadata[0].name # <--- IMPORTANTE
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.pk.private_key_pem
  }
}