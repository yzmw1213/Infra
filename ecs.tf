resource "aws_ecs_cluster" "portfolio-cluster-dev" {
  name = "${local.aws_ecs_cluster_name}-dev"
}

resource "aws_service_discovery_private_dns_namespace" "user_internal" {
  name = "user.internal"
  description = "service discovery dns namespace for user service"

  vpc = aws_vpc.portfolio-vpc-dev.id
}

# resource "aws_cloudwatch_log_group" "portfolio_cluster_log_group_dev" {
#   name = "portfolio-cluster-log-group-dev"
# }

resource "aws_service_discovery_service" "user_api_dev" {
  name = "dev-api"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.user_internal.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
