resource "aws_ecs_cluster" "portfolio_cluster" {
  name = local.aws_ecs_cluster_name
}

# サービス検出名前空間
resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "portfolio.product.internal"
  description = "service discovery dns namespace for user service"

  vpc = aws_vpc.portfolio_vpc.id
}

# フロントエンド サービス検出
resource "aws_service_discovery_service" "frontend" {
  name = "front"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

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

# ユーザーサービス サービス検出
resource "aws_service_discovery_service" "user_api" {
  name = "user"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

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

# 投稿サービス サービス検出
resource "aws_service_discovery_service" "post_api" {
  name = "post"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

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
