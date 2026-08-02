output "load_balancer_address" {
  description = "Public HTTPS address of the application."
  value       = "https://${yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}"
}

output "web_public_ips" {
  description = "Public addresses of the web servers, for SSH and Ansible."
  value       = [for vm in yandex_compute_instance.web : vm.network_interface.0.nat_ip_address]
}

output "web_private_ips" {
  description = "Private addresses of the web servers."
  value       = [for vm in yandex_compute_instance.web : vm.network_interface.0.ip_address]
}

output "postgresql_host" {
  description = "FQDN of the PostgreSQL host."
  value       = yandex_mdb_postgresql_cluster.this.host[0].fqdn
}

output "postgresql_connection" {
  description = "Connection string template for the application database."
  value       = "postgresql://${var.pg_user}@${yandex_mdb_postgresql_cluster.this.host[0].fqdn}:6432/${var.pg_database}"
}
