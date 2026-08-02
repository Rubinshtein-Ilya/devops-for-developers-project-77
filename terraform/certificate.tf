resource "yandex_cm_certificate" "app" {
  name    = "${var.project_name}-cert"
  domains = [var.domain_name]

  managed {
    challenge_type = "DNS_CNAME"
  }
}

data "yandex_cm_certificate" "app" {
  certificate_id  = yandex_cm_certificate.app.id
  wait_validation = true

  depends_on = [yandex_dns_recordset.acme]
}
