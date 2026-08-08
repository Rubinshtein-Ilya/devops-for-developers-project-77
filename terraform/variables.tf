variable "yc_zone" {
  description = "Default availability zone. Kazakhstan installation provides kz1-a only."
  type        = string
  default     = "kz1-a"
}

variable "project_name" {
  description = "Prefix for all resource names."
  type        = string
  default     = "project-77"
}

variable "domain_name" {
  description = "Domain the application is published under. Its DNS zone is managed here."
  type        = string
  default     = "rubinshtein.online"
}

variable "subnet_cidr" {
  description = "CIDR block of the application subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "web_instance_count" {
  description = "Number of web servers behind the load balancer."
  type        = number
  default     = 2
}

variable "web_image_family" {
  description = "Image family used for web servers."
  type        = string
  default     = "ubuntu-2404-lts"
}

variable "web_platform_id" {
  description = "Compute platform. Kazakhstan provides standard-v3 only."
  type        = string
  default     = "standard-v3"
}

variable "web_cores" {
  description = "vCPU per web server."
  type        = number
  default     = 2
}

variable "web_core_fraction" {
  description = "Guaranteed vCPU share per web server, in percent."
  type        = number
  default     = 20
}

variable "web_memory" {
  description = "RAM per web server, in GB."
  type        = number
  default     = 2
}

variable "web_disk_size" {
  description = "Boot disk size per web server, in GB."
  type        = number
  default     = 15
}

variable "web_preemptible" {
  description = "Run web servers as preemptible instances. Cheaper, but the cloud stops them within 24h."
  type        = bool
  default     = false
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key placed on web servers."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "pg_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "pg_resource_preset" {
  description = "Managed PostgreSQL host class. Kazakhstan runs Ice Lake only, so b1/b2 classes are unavailable."
  type        = string
  default     = "s3-c2-m8"
}

variable "pg_disk_size" {
  description = "Managed PostgreSQL disk size, in GB."
  type        = number
  default     = 10
}

variable "pg_database" {
  description = "Application database name."
  type        = string
  default     = "app"
}

variable "pg_user" {
  description = "Application database user."
  type        = string
  default     = "app"
}

variable "app_service_tag" {
  description = "Value of the service tag the Datadog agent reports with. Must match ansible/group_vars/all.yml."
  type        = string
  default     = "blog"
}

variable "datadog_site" {
  description = "Datadog site the account belongs to."
  type        = string
  default     = "datadoghq.com"
}
