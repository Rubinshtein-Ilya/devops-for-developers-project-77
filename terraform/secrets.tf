data "ansiblevault_path" "yc_service_account_key" {
  path = local.vault_file
  key  = "yc_service_account_key"
}

data "ansiblevault_path" "yc_cloud_id" {
  path = local.vault_file
  key  = "yc_cloud_id"
}

data "ansiblevault_path" "yc_folder_id" {
  path = local.vault_file
  key  = "yc_folder_id"
}

data "ansiblevault_path" "pg_password" {
  path = local.vault_file
  key  = "pg_password"
}

data "ansiblevault_path" "datadog_api_key" {
  path = local.vault_file
  key  = "datadog_api_key"
}

data "ansiblevault_path" "datadog_app_key" {
  path = local.vault_file
  key  = "datadog_app_key"
}

locals {
  vault_file = "./vault.yml"

  yc_service_account_key = sensitive(data.ansiblevault_path.yc_service_account_key.value)
  yc_cloud_id            = sensitive(data.ansiblevault_path.yc_cloud_id.value)
  yc_folder_id           = sensitive(data.ansiblevault_path.yc_folder_id.value)
  pg_password            = sensitive(data.ansiblevault_path.pg_password.value)
  datadog_api_key        = sensitive(data.ansiblevault_path.datadog_api_key.value)
  datadog_app_key        = sensitive(data.ansiblevault_path.datadog_app_key.value)

  datadog_enabled = data.ansiblevault_path.datadog_app_key.value != ""
}
