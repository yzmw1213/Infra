# ユーザーサービスのテンプレートファイル
data "template_file" "userservice-task-definition-template" {
  template = file("templates/userservice.json.tpl")
  vars = {
    CONTAINER_NAME = var.USERSERVICE_NAME
    DB_ADRESS = aws_ssm_parameter.USER_DB_ADRESS_DEV.value
    DB_NAME = aws_ssm_parameter.USER_DB_NAME_DEV.value
    DB_PASSWORD = aws_ssm_parameter.USER_DB_PASSWORD_DEV.value
    DB_USER = aws_ssm_parameter.USER_DB_USER_DEV.value
    REPOSITORY_URL = replace(aws_ecr_repository.userservice-dev.repository_url, "https://", "")
  }
}

# # ユーザーサービスのタスク定義
resource "aws_ecs_task_definition" "userservice-dev-task-definition" {
  family                = var.USERSERVICE_TASK_DEFINITION_NAME
  requires_compatibilities = ["FARGATE"]
  cpu    = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs-role.arn
  container_definitions = data.template_file.userservice-task-definition-template.rendered
}

# ユーザーサービスECS
resource "aws_ecs_service" "userservice-dev" {
  name            = "${var.USERSERVICE_NAME}-dev"
  cluster         = aws_ecs_cluster.portfolio-cluster-dev.id
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.userservice-dev-task-definition.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  # iam_role        = aws_iam_role.ecs-userservice-role.arn
  depends_on      = [ data.aws_lb_target_group.api ]

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    security_groups = [aws_security_group.user.id]
    subnets = [aws_subnet.private_api_1a.id, aws_subnet.private_api_1c.id ]
  }
}

# ユーザーECSセキュリティグループ
resource "aws_security_group" "user" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  name = "${var.USERSERVICE_NAME}-sg"
  description = "${var.SERVICE_NAME} security group for user"

  # for Docker Pull
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [ "0.0.0.0/0" ]
  }

  # for connection to UserDB
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = [ aws_subnet.private_db_1a.cidr_block,aws_subnet.private_db_1c.cidr_block ]
  }

  # for request from ALB
  # ingress {
  #   from_port = 50052
  #   to_port = 50052
  #   protocol = "tcp"
  #   cidr_blocks = ["10.0.0.0/16"]
  # }
}
