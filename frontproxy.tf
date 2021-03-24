# フロントエンドプロキシサービスのテンプレートファイル
data "template_file" "frontproxy_task_definition_template" {
  template = file("templates/frontproxy.json.tpl")
  vars = {
    CONTAINER_NAME = var.FRONTPROXY_NAME
    REPOSITORY_URL = replace(aws_ecr_repository.frontproxy.repository_url, "https://", "")
    ECSTASK_LOG_GROUP = aws_cloudwatch_log_group.frontproxy_ecstask_log_group.name
    REGION = var.AWS_REGION
  }
}

# フロントEnvoyのタスク定義
resource "aws_ecs_task_definition" "frontproxy_task_definition" {
  family                = var.FRONTPROXY_TASK_DEFINITION_NAME
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  # ALBでEnvoyコンテナへのヘルスチェックを行う。
  container_definitions = data.template_file.frontproxy_task_definition_template.rendered
}

# フロントEnvoy ECS
resource "aws_ecs_service" "frontproxy" {
  name            = var.FRONTPROXY_NAME
  cluster         = aws_ecs_cluster.portfolio_cluster.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.frontproxy_task_definition.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  platform_version = "1.3.0"

  lifecycle {
    ignore_changes = [ desired_count]
  }

  network_configuration {
    security_groups = [aws_security_group.public_frontproxy.id]
    subnets = [ aws_subnet.public_1a.id, aws_subnet.public_1c.id ]
    # public subnetにあるため、docker pull するために必要
    assign_public_ip = true
  }

	load_balancer {
    target_group_arn = data.aws_lb_target_group.api.arn
    container_name   = var.FRONTPROXY_NAME
    container_port   = "8080"
  }
}

# FrontEnvoy ECS セキュリティグループ
resource "aws_security_group" "public_frontproxy" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.FRONTPROXY_NAME}-public-sg"
  description = "${var.SERVICE_NAME} security group for front proxy"
}

# FrontEnvoy Docker Pull
resource "aws_security_group_rule" "frontproxy_internet_public_connect" {
  security_group_id = aws_security_group.public_frontproxy.id
  type = "egress"
  cidr_blocks     = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}

# FrontEnvoy connection from ALB
resource "aws_security_group_rule" "proxy_connect_from_alb" {
  security_group_id = aws_security_group.public_frontproxy.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block ]
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
}
