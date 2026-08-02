variable "yc_service_account_key" {
  description = "Contents of a service account authorized key in JSON format. Passed via TF_VAR_yc_service_account_key."
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud identifier. Passed via TF_VAR_yc_cloud_id."
  type        = string
  sensitive   = true
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder identifier. Passed via TF_VAR_yc_folder_id."
  type        = string
  sensitive   = true
}

variable "yc_zone" {
  description = "Default availability zone. Kazakhstan installation provides kz1-a only."
  type        = string
  default     = "kz1-a"
}
