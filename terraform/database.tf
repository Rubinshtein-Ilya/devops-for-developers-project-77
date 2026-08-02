resource "yandex_mdb_postgresql_cluster" "this" {
  name               = "${var.project_name}-pg"
  environment        = "PRESTABLE"
  network_id         = yandex_vpc_network.this.id
  security_group_ids = [yandex_vpc_security_group.postgresql.id]

  config {
    version = var.pg_version

    resources {
      resource_preset_id = var.pg_resource_preset
      disk_type_id       = "network-hdd"
      disk_size          = var.pg_disk_size
    }
  }

  host {
    zone      = var.yc_zone
    subnet_id = yandex_vpc_subnet.this.id
  }
}

resource "yandex_mdb_postgresql_user" "app" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = var.pg_user
  password   = var.pg_password
}

resource "yandex_mdb_postgresql_database" "app" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = var.pg_database
  owner      = yandex_mdb_postgresql_user.app.name
}
