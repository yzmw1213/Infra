# フロントエンドのテンプレートファイル
data "template_file" "frontend-task-definition-template" {
  template = file("templates/frontend.json.tpl")
  vars = {
    CONTAINER_NAME = var.FRONTEND_NAME
    REPOSITORY_URL = replace(aws_ecr_repository.frontend-dev.repository_url, "https://", "")
  }
}

# フロントエンドのタスク定義
resource "aws_ecs_task_definition" "frontend-dev-task-definition" {
  family                = var.FRONTEND_TASK_DEFINITION_NAME
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs-role.arn
  container_definitions = data.template_file.frontend-task-definition-template.rendered
}

# フロントエンド ECS
resource "aws_ecs_service" "frontend-dev" {
  name            = "${var.FRONTEND_NAME}-dev"
  cluster         = aws_ecs_cluster.portfolio-cluster-dev.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.frontend-dev-task-definition.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  depends_on      = [ aws_lb_target_group.front ]

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = [aws_security_group.front.id]
    subnets = [aws_subnet.public_1a.id, aws_subnet.public_1c.id ]
    # public subnetにあるため、docker pull するために必要
    assign_public_ip = true
  }

	load_balancer {
    target_group_arn = aws_lb_target_group.front.arn
    container_name   = var.FRONTEND_NAME
    container_port   = "3000"
  }
}

# フロントエンドECSセキュリティグループ
resource "aws_security_group" "front" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  name = "${var.SERVICE_NAME}-front"
  description = "${var.SERVICE_NAME} security group for front"

  # for Docker Pull
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 8080
    protocol = "tcp"
	  cidr_blocks = [ aws_vpc.portfolio-vpc-dev.cidr_block ]
  }
}

resource "aws_lb" "front-alb" {
  name = var.FRONT_LOAD_BALANCER_NAME
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.front_alb.id]
  subnets = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]
  idle_timeout = 120

  access_logs {
    bucket  = aws_s3_bucket.portfolio_access_logs_dev.bucket
    prefix  = "front-alb"
    enabled = true
  }
}

resource "aws_lb_listener"  "front-alb" {
  load_balancer_arn = aws_lb.front-alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.id
  }
}

resource "aws_lb_listener_rule" "front" {
  # ルールを追加するリスナー
  listener_arn = aws_lb_listener.front-alb.arn

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.id
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# ALB SSL化
# resource "aws_lb_listener"  "front_ssl" {
#   load_balancer_arn = aws_lb.front-alb.arn
#   port = "443"
#   protocol = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn = data.aws_acm_certificate.issued.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front.arn
#   }
# }

resource "aws_lb_target_group" "front" {
  name     = "${var.SERVICE_NAME}-front-dev"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.portfolio-vpc-dev.id

  health_check {
    port = 3000
    path = "/health"
  }
}

resource "aws_security_group" "front_alb" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  name = "${var.SERVICE_NAME}-front-alb"
  description = "${var.SERVICE_NAME} security group for front alb"

	# インターネットからセキュリティグループ内のリソースへのアクセス許可設定
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

	# 同一VPC内での通信許可
  egress {
    from_port = 80
    to_port = 8080
    protocol = "tcp"
	  cidr_blocks = [ aws_vpc.portfolio-vpc-dev.cidr_block ]
  }
}