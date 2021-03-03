# Nuxtアプリケーション ALB
resource "aws_lb" "app_alb" {
  name = var.FRONT_LOAD_BALANCER_NAME
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.app_alb.id]
  subnets = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]
  idle_timeout = 120

  access_logs {
    bucket  = aws_s3_bucket.portfolio_access_logs.bucket
    prefix  = "front-alb"
    enabled = true
  }
}

# Nuxtアプリケーション ALBリスナー
resource "aws_lb_listener"  "alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.id
  }
}

# Nuxtアプリケーション ターゲットグループ
resource "aws_lb_target_group" "front" {
  name     = "${var.SERVICE_NAME}-front"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.portfolio_vpc.id

  health_check {
    port = 3000
    path = "/health"
  }
}

# gRPC プロトコルを許可する仕様がterraformで未実装のため、ターゲットグループはコンソール上で作成
# https://github.com/hashicorp/terraform-provider-aws/issues/15929d
data "aws_lb_target_group" "api" {
  name     = "${var.SERVICE_NAME}-tg-api"
}

# ALBリスナールール バックエンドへのルーティング
resource "aws_lb_listener_rule" "api" {
  # ルールを追加するリスナー
  listener_arn = aws_lb_listener.alb_listener.arn

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api.arn
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      # values = ["/api/*"]
      values = [
        "/userservice.UserService/*",
        "/postservice.PostService/*",
        "/tagservice.TagService/*",
      ]
    }
  }
}

# フロントエンドALBセキュリティグループ
resource "aws_security_group" "app_alb" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.SERVICE_NAME}-front-alb"
  description = "${var.SERVICE_NAME} security group for app alb"
}

# フロントエンドALBセキュリティグループルール
# HTTPSリクエスト
resource "aws_security_group_rule" "alb_https_access" {
  security_group_id = aws_security_group.app_alb.id
  type = "ingress"
  cidr_blocks     = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

# フロントエンドALBセキュリティグループルール
# Nuxtアプリケーションへの通信
resource "aws_security_group_rule" "front_access_from_alb" {
  security_group_id = aws_security_group.app_alb.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block ]
  from_port = 3000
  to_port = 3000
  protocol = "tcp"
}

# FrontProxy ターゲットへの通信許可
resource "aws_security_group_rule" "alb_egress_proxy" {
  security_group_id = aws_security_group.app_alb.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block ]
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
}
