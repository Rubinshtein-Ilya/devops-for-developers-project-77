resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "web" {
  private_key_pem = tls_private_key.web.private_key_pem

  subject {
    common_name  = "${var.project_name}.local"
    organization = "Hexlet DevOps Project 77"
  }

  dns_names = ["${var.project_name}.local"]

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "yandex_cm_certificate" "web" {
  name = "${var.project_name}-cert"

  self_managed {
    certificate = tls_self_signed_cert.web.cert_pem
    private_key = tls_private_key.web.private_key_pem
  }
}
