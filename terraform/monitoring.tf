resource "datadog_monitor" "app_http" {
  count = var.datadog_app_key == "" ? 0 : 1

  name = "[${var.project_name}] application does not answer over HTTP"
  type = "service check"

  query = "\"http.can_connect\".over(\"service:${var.app_service_tag}\").by(\"host\").last(4).count_by_status()"

  message = <<-EOT
    The Datadog agent cannot reach the application on {{host.name}}.

    The agent requests http://127.0.0.1/ locally, so a failure means the
    container is down or not serving requests. The load balancer will take the
    host out of rotation, and if both hosts fail the site goes down.

    Check the container first: `docker ps` and `docker logs blog`.
  EOT

  monitor_thresholds {
    ok       = 1
    warning  = 2
    critical = 3
  }

  notify_no_data    = true
  no_data_timeframe = 10
  renotify_interval = 60
  include_tags      = true

  tags = [
    "project:${var.project_name}",
    "service:${var.app_service_tag}",
    "managed-by:terraform",
  ]
}
