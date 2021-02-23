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
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id = aws_subnet.ec2_public_1a.id
  key_name = aws_key_pair.ec2_key.id

  tags = {
    Name = "${var.SERVICE_NAME}-ec2-rds_connect"
  }
}

# Elastic IP Adress for ec2
resource "aws_eip" "ec2_eip" {
  instance = aws_instance.rds_connect.id
  vpc = true
}

# Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name = "ec2_key"
  public_key = file("keys/portfolio_ec2.pub")
}

resource "aws_route_table_association" "ec2_public_1a" {
	subnet_id      = aws_subnet.ec2_public_1a.id
	route_table_id = aws_route_table.public.id
}
