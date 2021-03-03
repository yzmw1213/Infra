# 最新版のAmazonLinux2のAMI情報
data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

#  EC2 インスタンス
resource "aws_instance" "rds_connect" {
  ami = data.aws_ami.linux2.image_id
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id = aws_subnet.ec2_public_1a.id
  key_name = aws_key_pair.ec2_key.id

  tags = {
    Name = "${var.SERVICE_NAME}-ec2-rds_connect"
  }
}

# Elastic IP Adress for ec2
# resource "aws_eip" "ec2_eip" {
#   instance = aws_instance.rds_connect.id
#   vpc = true
# }

# Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name = "ec2_key"
  public_key = file("keys/portfolio_ec2.pub")
}

resource "aws_route_table_association" "ec2_public_1a" {
	subnet_id      = aws_subnet.ec2_public_1a.id
	route_table_id = aws_route_table.public.id
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

# EC2からユーザーRDS接続許可
resource "aws_security_group_rule" "ec2_userDB_connect" {
  security_group_id = aws_security_group.ec2.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.private_user_db_1a.cidr_block,aws_subnet.private_user_db_1c.cidr_block ]
  from_port = aws_db_instance.rds_userDB.port
  to_port = aws_db_instance.rds_userDB.port
  protocol = "tcp"
}

# EC2から投稿RDS接続許可
resource "aws_security_group_rule" "ec2_postDB_connect" {
  security_group_id = aws_security_group.ec2.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.private_post_db_1a.cidr_block,aws_subnet.private_post_db_1c.cidr_block ]
  from_port = aws_db_instance.rds_postDB.port
  to_port = aws_db_instance.rds_postDB.port
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
