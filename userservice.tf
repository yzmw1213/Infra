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
    subnets = [ aws_subnet.private_user_api_1c.id, aws_subnet.private_user_api_1c.id ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.user_api.arn
  }
}
