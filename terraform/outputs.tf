output "app_url" {
  description = "Public address of the application."
  value       = "https://${var.domain_name}"
}

output "load_balancer_ip" {
  description = "Static public address of the load balancer."
  value       = yandex_vpc_address.alb.external_ipv4_address[0].address
}

output "dns_name_servers" {
  description = "Name servers to set at the domain registrar."
  value       = ["ns1.yandexcloud.kz", "ns2.yandexcloud.kz"]
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
