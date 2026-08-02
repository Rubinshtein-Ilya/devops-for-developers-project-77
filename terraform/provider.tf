terraform {
  required_version = ">= 1.6.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.220"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.yc_service_account_key

  cloud_id         = var.yc_cloud_id
  folder_id        = var.yc_folder_id
  zone             = var.yc_zone
  endpoint         = "api.yandexcloud.kz:443"
  storage_endpoint = "https://storage.yandexcloud.kz"
}
