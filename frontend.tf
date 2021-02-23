# フロントエンドのテンプレートファイル
data "template_file" "frontend_task_definition_template" {
  template = file("templates/frontend.json.tpl")
  vars = {
    CONTAINER_NAME = var.FRONTEND_NAME
    REPOSITORY_URL = replace(aws_ecr_repository.frontend.repository_url, "https://", "")
    PROXY_REPOSITORY_URL = replace(aws_ecr_repository.frontproxy.repository_url, "https://", "")
    API_DNS = "https://${aws_route53_record.hostzone_record_api.name}"
    ECSTASK_LOG_GROUP = aws_cloudwatch_log_group.frontend_ecstask_log_group.name
    REGION = var.AWS_REGION
  }
}

# フロントエンドのタスク定義
resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                = var.FRONTEND_NAME
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  container_definitions = data.template_file.frontend_task_definition_template.rendered
}

# フロントエンド ECS
resource "aws_ecs_service" "frontend" {
  name            = var.FRONTEND_NAME
  cluster         = aws_ecs_cluster.portfolio_cluster.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  depends_on      = [ aws_lb.front_alb ]

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = [aws_security_group.front.id]
    subnets = [ aws_subnet.public_1a.id, aws_subnet.public_1c.id ]
    # public subnetにあるため、docker pull するために必要
    assign_public_ip = true
  }

	load_balancer {
    target_group_arn = aws_lb_target_group.front.arn
    container_name   = var.FRONTEND_NAME
    container_port   = "3000"
  }
}
