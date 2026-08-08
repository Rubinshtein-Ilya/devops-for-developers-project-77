data "yandex_compute_image" "web" {
  family = var.web_image_family
}

resource "yandex_compute_instance" "web" {
  count = var.web_instance_count

  name        = "${var.project_name}-web-${count.index + 1}"
  hostname    = "${var.project_name}-web-${count.index + 1}"
  platform_id = var.web_platform_id
  zone        = var.yc_zone

  allow_stopping_for_update = true

  resources {
    cores         = var.web_cores
    core_fraction = var.web_core_fraction
    memory        = var.web_memory
  }

  scheduling_policy {
    preemptible = var.web_preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.web.id
      size     = var.web_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.this.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
    })
  }

  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image_id,
    ]
  }
}
