resource "yandex_dns_zone" "this" {
  name   = "${var.project_name}-zone"
  zone   = "${var.domain_name}."
  public = true
}

resource "yandex_dns_recordset" "acme" {
  zone_id = yandex_dns_zone.this.id
  name    = yandex_cm_certificate.app.challenges[0].dns_name
  type    = yandex_cm_certificate.app.challenges[0].dns_type
  ttl     = 60
  data    = [yandex_cm_certificate.app.challenges[0].dns_value]
}

resource "yandex_dns_recordset" "app" {
  zone_id = yandex_dns_zone.this.id
  name    = "${var.domain_name}."
  type    = "A"
  ttl     = 300
  data    = [yandex_vpc_address.alb.external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "www" {
  zone_id = yandex_dns_zone.this.id
  name    = "www.${var.domain_name}."
  type    = "CNAME"
  ttl     = 300
  data    = ["${var.domain_name}."]
}
