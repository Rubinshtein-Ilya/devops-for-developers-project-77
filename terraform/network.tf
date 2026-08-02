resource "yandex_vpc_network" "this" {
  name = "${var.project_name}-network"
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.project_name}-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.subnet_cidr]
}

resource "yandex_vpc_security_group" "alb" {
  name       = "${var.project_name}-alb-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP from anywhere, redirected to HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol          = "TCP"
    description       = "Load balancer health checks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }

  egress {
    protocol       = "ANY"
    description    = "Any outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "${var.project_name}-web-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol          = "TCP"
    description       = "HTTP from the load balancer"
    security_group_id = yandex_vpc_security_group.alb.id
    port              = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "Health checks from the load balancer"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH for provisioning"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Any outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "postgresql" {
  name       = "${var.project_name}-pg-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    protocol          = "TCP"
    description       = "PostgreSQL from web servers"
    security_group_id = yandex_vpc_security_group.web.id
    port              = 6432
  }

  egress {
    protocol       = "ANY"
    description    = "Any outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
