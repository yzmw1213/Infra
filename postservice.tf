# 投稿サービスのテンプレートファイル
data "template_file" "postservice_task_definition_template" {
  template = file("templates/postservice.json.tpl")
  vars = {
    CONTAINER_NAME = var.POSTSERVICE_NAME
    DB_ADRESS = aws_ssm_parameter.POST_DB_ADRESS.value
    DB_NAME = aws_ssm_parameter.POST_DB_NAME.value
    DB_PASSWORD = aws_ssm_parameter.POST_DB_PASSWORD.value
    DB_USER = aws_ssm_parameter.POST_DB_USER.value
    USER_URL = "${aws_service_discovery_service.user_api.name}.${aws_service_discovery_private_dns_namespace.internal.name}:8082"
    REPOSITORY_URL = replace(aws_ecr_repository.postservice.repository_url, "https://", "")
    PROXY_REPOSITORY_URL = replace(aws_ecr_repository.postproxy.repository_url, "https://", "")
    ECSTASK_LOG_GROUP = aws_cloudwatch_log_group.postservice_ecstask_log_group.name
    REGION = var.AWS_REGION
  }
}

# 投稿サービスのタスク定義
resource "aws_ecs_task_definition" "postservice_task_definition" {
  family                = var.POSTSERVICE_NAME
  requires_compatibilities = ["FARGATE"]
  cpu    = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  container_definitions = data.template_file.postservice_task_definition_template.rendered
}

# 投稿サービスECS
resource "aws_ecs_service" "postservice" {
  name            = var.POSTSERVICE_NAME
  cluster         = aws_ecs_cluster.portfolio_cluster.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.postservice_task_definition.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = [ aws_security_group.post.id ]
    subnets = [ aws_subnet.private_post_api_1a.id, aws_subnet.private_post_api_1c.id ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.post_api.arn
  }
}

# 投稿サービスECSセキュリティグループ
resource "aws_security_group" "post" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.POSTSERVICE_NAME}-sg"
  description = "${var.SERVICE_NAME} security group for post"
}

# 投稿サービスからRDSへ接続許可
# resource "aws_security_group_rule" "post_rds_connect" {
#   security_group_id = aws_security_group.post.id
#   type = "egress"
#   cidr_blocks     = [ aws_subnet.private_post_db_1a.cidr_block,aws_subnet.private_post_db_1c.cidr_block ]
#   from_port = aws_db_instance.rds_postDB.port
#   to_port = aws_db_instance.rds_postDB.port
#   protocol = "tcp"
# }

# 投稿サービス フロントEnvoyからの接続許可
resource "aws_security_group_rule" "post_connect_from_envoy" {
  security_group_id = aws_security_group.post.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block ]
  from_port = 8081
  to_port = 8081
  protocol = "tcp"
}

# 投稿サービス ユーザーサービスへの接続許可
resource "aws_security_group_rule" "post_connect_to_user" {
  security_group_id = aws_security_group.post.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.private_user_api_1a.cidr_block, aws_subnet.private_user_api_1c.cidr_block ]
  from_port = 8082
  to_port = 8082
  protocol = "tcp"
}

# for Docker Pull
resource "aws_security_group_rule" "post_internet_connect" {
  security_group_id = aws_security_group.post.id
  type = "egress"
  cidr_blocks     = [ "0.0.0.0/0" ]
  from_port = 443
  to_port = 443
  protocol = "tcp"
}
