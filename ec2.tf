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

resource "aws_instance" "rds_connect" {
  ami = data.aws_ami.linux2.image_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_dev.id]
  subnet_id = aws_subnet.ec2_public_1a.id
  key_name = aws_key_pair.ec2_key_dev.id

  tags = {
    Name = "${var.SERVICE_NAME}-ec2-rds_connect"
  }
}

#Elastic IP Adress for ec2
resource "aws_eip" "ec2_dev" {
  instance = aws_instance.rds_connect.id
  vpc = true
}

# Key Pair
resource "aws_key_pair" "ec2_key_dev" {
  key_name = "ec2_key_dev"
  public_key = file("keys/portfolio_ec2_dev.pub")
}

resource "aws_route_table_association" "ec2_public_1a" {
	subnet_id      = aws_subnet.ec2_public_1a.id
	route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_dev" {
	vpc_id = aws_vpc.portfolio-vpc-dev.id
  name = "${var.SERVICE_NAME}-dev-front"

  tags = {
    Name = "sg_ec2_dev"
  }
}

# ssh 接続
resource "aws_security_group_rule" "in_ssh" {
  security_group_id = aws_security_group.ec2_dev.id
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

# rds接続
resource "aws_security_group_rule" "ec2_mysql_connect" {
  security_group_id = aws_security_group.ec2_dev.id
  type = "egress"
  cidr_blocks     = [ aws_subnet.private_db_1a.cidr_block,aws_subnet.private_db_1c.cidr_block ]
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
}

# ec2内で install コマンド用
resource "aws_security_group_rule" "ec2_internet_connect" {
  security_group_id = aws_security_group.ec2_dev.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}