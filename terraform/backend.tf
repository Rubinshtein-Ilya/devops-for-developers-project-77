terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.kz"
    }

    bucket = "tfstate-rubinshtein-77"
    region = "kz1"
    key    = "project-77/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
