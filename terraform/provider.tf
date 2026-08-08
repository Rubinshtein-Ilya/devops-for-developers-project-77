terraform {
  required_version = ">= 1.6.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.220"
    }

    datadog = {
      source  = "DataDog/datadog"
      version = "~> 4.17"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    ansiblevault = {
      source  = "MeilleursAgents/ansiblevault"
      version = "~> 3.0"
    }
  }
}

provider "ansiblevault" {
  root_folder = abspath(local.ansible_dir)
  vault_path  = abspath("${local.ansible_dir}/.vault_pass")
}

provider "datadog" {
  api_key = local.datadog_api_key
  app_key = local.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

provider "yandex" {
  service_account_key_file = local.yc_service_account_key

  cloud_id         = local.yc_cloud_id
  folder_id        = local.yc_folder_id
  zone             = var.yc_zone
  endpoint         = "api.yandexcloud.kz:443"
  storage_endpoint = "https://storage.yandexcloud.kz"
}
