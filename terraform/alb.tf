resource "yandex_alb_target_group" "web" {
  name = "${var.project_name}-tg"

  dynamic "target" {
    for_each = yandex_compute_instance.web

    content {
      subnet_id  = yandex_vpc_subnet.this.id
      ip_address = target.value.network_interface.0.ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "${var.project_name}-bg"

  http_backend {
    name             = "web"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout             = "2s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 3

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "${var.project_name}-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "${var.project_name}-vh"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "default"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name               = "${var.project_name}-alb"
  network_id         = yandex_vpc_network.this.id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.this.id
    }
  }

  listener {
    name = "https"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [443]
    }

    tls {
      default_handler {
        certificate_ids = [yandex_cm_certificate.web.id]

        http_handler {
          http_router_id = yandex_alb_http_router.web.id
        }
      }
    }
  }
}
