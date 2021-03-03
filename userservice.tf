# ユーザーサービスのテンプレートファイル
data "template_file" "userservice_task_definition_template" {
  template = file("templates/userservice.json.tpl")
  vars = {
    CONTAINER_NAME = var.USERSERVICE_NAME
    DB_ADRESS = aws_ssm_parameter.USER_DB_ADRESS.value
    DB_NAME = aws_ssm_parameter.USER_DB_NAME.value
    DB_PASSWORD = aws_ssm_parameter.USER_DB_PASSWORD.value
    DB_USER = aws_ssm_parameter.USER_DB_USER.value
    REPOSITORY_URL = replace(aws_ecr_repository.userservice.repository_url, "https://", "")
    PROXY_REPOSITORY_URL = replace(aws_ecr_repository.userproxy.repository_url, "https://", "")
    ECSTASK_LOG_GROUP = aws_cloudwatch_log_group.userservice_ecstask_log_group.name
    REGION = var.AWS_REGION
  }
}

# ユーザーサービスのタスク定義
resource "aws_ecs_task_definition" "userservice_task_definition" {
  family                = var.USERSERVICE_NAME
  requires_compatibilities = ["FARGATE"]
  cpu    = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  container_definitions = data.template_file.userservice_task_definition_template.rendered
}

# ユーザーサービスECS
resource "aws_ecs_service" "userservice" {
  name            = var.USERSERVICE_NAME
  cluster         = aws_ecs_cluster.portfolio_cluster.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.userservice_task_definition.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = [ aws_security_group.user.id ]
    subnets = [ aws_subnet.private_user_api_1a.id, aws_subnet.private_user_api_1c.id ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.user_api.arn
  }
}

# ユーザーサービスECSセキュリティグループ
resource "aws_security_group" "user" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.USERSERVICE_NAME}-sg"
  description = "${var.SERVICE_NAME} security group for user"
}

# ユーザーサービスからRDSへ接続許可
resource "aws_security_group_rule" "user_rds_connect" {
  security_group_id = aws_security_group.user.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.private_user_db_1a.cidr_block,aws_subnet.private_user_db_1c.cidr_block ]
  from_port = aws_db_instance.rds_userDB.port
  to_port = aws_db_instance.rds_userDB.port
  protocol = "tcp"
}

# ユーザーサービス フロントEnvoy, 投稿サービスからの接続許可
resource "aws_security_group_rule" "user_connect_from_otherservices" {
  security_group_id = aws_security_group.user.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block, aws_subnet.private_post_api_1a.cidr_block, aws_subnet.private_post_api_1c.cidr_block ]
  from_port = 8082
  to_port = 8082
  protocol = "tcp"
}

# for Docker Pull
resource "aws_security_group_rule" "user_internet_connect" {
  security_group_id = aws_security_group.user.id
  type = "egress"
  cidr_blocks     = [ "0.0.0.0/0" ]
  from_port = 443
  to_port = 443
  protocol = "tcp"
}
