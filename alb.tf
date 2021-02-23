# Nuxtアプリケーション ALB
resource "aws_lb" "front_alb" {
  name = var.FRONT_LOAD_BALANCER_NAME
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.front_alb.id]
  subnets = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]
  idle_timeout = 120

  access_logs {
    bucket  = aws_s3_bucket.portfolio_access_logs.bucket
    prefix  = "front-alb"
    enabled = true
  }
}

# フロントEnvoy　ALB
resource "aws_lb" "api_alb" {
  name = var.API_LOAD_BALANCER_NAME
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.api_alb.id]
  #同一サーバーを複数のサブネットに立てるのかどうか。
  subnets = [ aws_subnet.public_api_lb_1a.id, aws_subnet.public_api_lb_1c.id ]
  # アクセスログを保存するバケットを指定
  access_logs {
    bucket  = aws_s3_bucket.portfolio_api_access_logs.bucket
    prefix  = "front-alb"
    enabled = true
  }
}

# Nuxtアプリケーション ALBリスナー
resource "aws_lb_listener"  "front_alb_listener" {
  load_balancer_arn = aws_lb.front_alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.id
  }
}

# フロントEnvoyのALBリスナー
resource "aws_lb_listener"  "api_alb_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.api.arn
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

# Nuxtアプリケーション ALBリスナールール
resource "aws_lb_listener_rule" "front" {
  # ルールを追加するリスナー
  listener_arn = aws_lb_listener.front_alb_listener.arn

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
