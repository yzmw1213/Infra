# VPCエンドポイントにアタッチするセキュリティグループ
resource "aws_security_group" "private_link" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.SERVICE_NAME}-private-link-endpoint"
  description = "${var.SERVICE_NAME} security group for vpc endpoint"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ aws_subnet.private_user_api_1a.cidr_block, aws_subnet.private_user_api_1c.cidr_block, aws_subnet.private_post_api_1a.cidr_block, aws_subnet.private_post_api_1c.cidr_block, aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block, aws_subnet.public_api_lb_1a.cidr_block, aws_subnet.public_api_lb_1c.cidr_block ]
  }
}

# フロントエンドECSセキュリティグループ
resource "aws_security_group" "front" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.SERVICE_NAME}-front"
  description = "${var.SERVICE_NAME} security group for front"
}

# ユーザーサービスECSセキュリティグループ
resource "aws_security_group" "user" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.USERSERVICE_NAME}-sg"
  description = "${var.SERVICE_NAME} security group for user"
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

# for Docker Pull
resource "aws_security_group_rule" "front_internet_access" {
  security_group_id = aws_security_group.front.id
  type = "egress"
  cidr_blocks     = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}

# フロントエンドALBセキュリティグループ
resource "aws_security_group" "front_alb" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.SERVICE_NAME}-front-alb"
  description = "${var.SERVICE_NAME} security group for front alb"
}

# フロントEnvoy ALBセキュリティグループ
resource "aws_security_group" "api_alb" {
  vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.SERVICE_NAME}-api-sg"
  description = "${var.SERVICE_NAME} security group for api alb"
}

# ALBヘルスチェックからの通信許可
resource "aws_security_group_rule" "front_healthcheck" {
  security_group_id = aws_security_group.front.id
  type = "ingress"
  cidr_blocks     = [aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block]
  from_port = 3000
  to_port = 3000
  protocol = "tcp"
}

# フロントエンドALBセキュリティグループルール
# HTTPSリクエスト
resource "aws_security_group_rule" "front_alb_https_access" {
  security_group_id = aws_security_group.front_alb.id
  type = "ingress"
  cidr_blocks     = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

# フロントエンドALBセキュリティグループルール
# Nuxtアプリケーションへの通信
resource "aws_security_group_rule" "front_alb_access_from_alb" {
  security_group_id = aws_security_group.front_alb.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.public_1a.cidr_block, aws_subnet.public_1c.cidr_block ]
  from_port = 3000
  to_port = 3000
  protocol = "tcp"
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
  cidr_blocks     = [ aws_subnet.public_api_lb_1a.cidr_block, aws_subnet.public_api_lb_1c.cidr_block ]
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
}

resource "aws_security_group_rule" "proxy_connect_from_alb_ssl" {
  security_group_id = aws_security_group.public_frontproxy.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.public_api_lb_1a.cidr_block, aws_subnet.public_api_lb_1c.cidr_block ]
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

# FrontProxy ターゲットへの通信許可
resource "aws_security_group_rule" "api_lb_user_internal" {
  security_group_id = aws_security_group.api_alb.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.public_api_lb_1a.cidr_block, aws_subnet.public_api_lb_1c.cidr_block ]
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
}

# FrontProxy ターゲットへの通信許可
resource "aws_security_group_rule" "api_lb_front_proxy_ssl" {
  security_group_id = aws_security_group.api_alb.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.public_api_lb_1a.cidr_block, aws_subnet.public_api_lb_1c.cidr_block ]
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

# FrontProxy HTTPS通信許可
resource "aws_security_group_rule" "api_lb_ssl" {
  security_group_id = aws_security_group.api_alb.id
  type = "ingress"
  cidr_blocks     = [ "0.0.0.0/0"]
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

# FrontProxy HTTPS通信許可
resource "aws_security_group_rule" "api_lb_req" {
  security_group_id = aws_security_group.api_alb.id
  type = "ingress"
  cidr_blocks     = [ "0.0.0.0/0"]
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
}

resource "aws_security_group_rule" "api" {
  security_group_id = aws_security_group.api_alb.id
  type = "ingress"
  cidr_blocks     = [ "0.0.0.0/0" ]
  from_port = 80
  to_port = 80
  protocol = "tcp"
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

# ユーザーサービス フロントEnvoyからの接続許可
resource "aws_security_group_rule" "user_connect_from_envoy" {
  security_group_id = aws_security_group.user.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.public_api_lb_1a.cidr_block, aws_subnet.public_api_lb_1c.cidr_block ]
  from_port = 8082
  to_port = 8082
  protocol = "tcp"
}

# EC2セキュリティグループ
resource "aws_security_group" "ec2" {
	vpc_id = aws_vpc.portfolio_vpc.id
  name = "${var.SERVICE_NAME}-ec2"

  tags = {
    Name = "sg_ec2"
  }
}

# EC2 ssh 接続許可
resource "aws_security_group_rule" "in_ssh" {
  security_group_id = aws_security_group.ec2.id
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

# # EC2からRDS接続許可
resource "aws_security_group_rule" "ec2_mysql_connect" {
  security_group_id = aws_security_group.ec2.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.private_db_1a.cidr_block,aws_subnet.private_db_1c.cidr_block ]
  from_port = aws_db_instance.rds_userDB.port
  to_port = aws_db_instance.rds_userDB.port
  protocol = "tcp"
}

# インターネットへのアクセス許可
# mysqlなどのコマンドインストール
resource "aws_security_group_rule" "ec2_internet_connect" {
  security_group_id = aws_security_group.ec2.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}
