# Internet VPC
resource "aws_vpc" "portfolio_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false

  tags =  {
    Name = "portfolio-vpc"
  }
}

resource "aws_subnet" "ec2_public_1a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.101.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-ec2-public-1a"
  }
}

resource "aws_subnet" "ec2_public_1c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.102.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-ec2-public-1c"
  }
}

# フロントエンドECSのサブネット
resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-public-1a"
  }
}

# フロントエンドECSのサブネット
resource "aws_subnet" "public_1c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-public-1c"
  }
}

# フロントエンド APIプロキシ ECSのサブネット
resource "aws_subnet" "public_api_lb_1a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-public-api-1a"
  }
}

# フロントエンド APIプロキシ ECSのサブネット
resource "aws_subnet" "public_api_lb_1c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-public-api-1c"
  }
}


# ユーザーサービスECSのサブネット
resource "aws_subnet" "private_user_api_1a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-user-private-1a"
  }
}

# ユーザーサービスECSのサブネット
resource "aws_subnet" "private_user_api_1c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-user-private-1c"
  }
}

# 投稿サービスECSのサブネット
resource "aws_subnet" "private_post_api_1a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.30.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-post-private-1a"
  }
}

# 投稿サービスECSのサブネット
resource "aws_subnet" "private_post_api_1c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.31.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-post-private-1c"
  }
}

# ユーザーRDSのサブネット
resource "aws_subnet" "private_user_db_1a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.20.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.USER_RDS_NAME}-private-1a"
  }
}

# ユーザーRDSのサブネット
resource "aws_subnet" "private_user_db_1c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.21.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.USER_RDS_NAME}-private-1c"
  }
}

# 投稿RDSのサブネット
resource "aws_subnet" "private_post_db_1a" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.40.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.POST_RDS_NAME}-private-1a"
  }
}

# 投稿RDSのサブネット
resource "aws_subnet" "private_post_db_1c" {
  vpc_id = aws_vpc.portfolio_vpc.id
  cidr_block = "10.0.41.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.POST_RDS_NAME}-private-1c"
  }
}

# IGW
resource "aws_internet_gateway" "portfolio_igw" {
  vpc_id = aws_vpc.portfolio_vpc.id
  
  tags = {
    Part = "${var.SERVICE_NAME}-gw"
  }
}

# フロントエンド アプリケーション ルートテーブル
resource "aws_route_table" "public" {
	vpc_id = aws_vpc.portfolio_vpc.id

	tags = {
		Name = "${var.SERVICE_NAME}-public"
	}
}

# フロントエンド APIプロキシ ルートテーブル 
resource "aws_route_table" "public_api" {
	vpc_id = aws_vpc.portfolio_vpc.id

	tags = {
		Name = "${var.SERVICE_NAME}-public-api"
	}
}

# Route
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.portfolio_igw.id
}

# Association
resource "aws_route_table_association" "public_1a" {
	subnet_id      = aws_subnet.public_1a.id
	route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_1c" {
	subnet_id      = aws_subnet.public_1c.id
	route_table_id = aws_route_table.public.id
}

# Route Table (User Private)
resource "aws_route_table" "private_user_api" {
	vpc_id = aws_vpc.portfolio_vpc.id

	tags = {
		Name = "${var.SERVICE_NAME}-user-private"
	}
}

# Association
resource "aws_route_table_association" "private_user_1a" {
	subnet_id      = aws_subnet.private_user_api_1a.id
	route_table_id = aws_route_table.private_user_api.id
}
resource "aws_route_table_association" "private_user_1c" {
	subnet_id      = aws_subnet.private_user_api_1c.id
	route_table_id = aws_route_table.private_user_api.id
}

# Route Table (Post Private)
resource "aws_route_table" "private_post_api" {
	vpc_id = aws_vpc.portfolio_vpc.id

	tags = {
		Name = "${var.SERVICE_NAME}-post-private"
	}
}

# Association
resource "aws_route_table_association" "private_post_1a" {
	subnet_id      = aws_subnet.private_post_api_1a.id
	route_table_id = aws_route_table.private_post_api.id
}
resource "aws_route_table_association" "private_post_1c" {
	subnet_id      = aws_subnet.private_post_api_1c.id
	route_table_id = aws_route_table.private_post_api.id
}

# Route Table (public-api)
resource "aws_route" "public-api" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_api.id
  gateway_id             = aws_internet_gateway.portfolio_igw.id
}

# Association
resource "aws_route_table_association" "public_frontproxy_1a" {
	subnet_id      = aws_subnet.public_api_lb_1a.id
	route_table_id = aws_route_table.public_api.id
}
resource "aws_route_table_association" "public_frontproxy_1c" {
	subnet_id      = aws_subnet.public_api_lb_1c.id
	route_table_id = aws_route_table.public_api.id
}

# endpoint for docker pull
resource "aws_vpc_endpoint" "portfolio_ecr_dkr" {
  vpc_id = aws_vpc.portfolio_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  # subnet_ids = [ aws_subnet.private_api_1a.id, aws_subnet.private_api_1c.id, aws_subnet.public_api_lb_1a.id, aws_subnet.public_api_lb_1c.id ]
  subnet_ids = [ aws_subnet.private_user_api_1a.id, aws_subnet.private_user_api_1c.id ]
  security_group_ids = [
    aws_security_group.private_link.id
  ]
  private_dns_enabled = true

	tags = {
		Name = "${var.SERVICE_NAME}-vpc-endpoint-for-ecr-dkr"
	}
}

# endpoint for docker pull
resource "aws_vpc_endpoint" "portfolio_ecr_s3" {
  vpc_id = aws_vpc.portfolio_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
      "Sid": "Access-to-specific-bucket-only",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::prod-ap-northeast-1-starport-layer-bucket/*"]
      }
    ]
  }
  EOF

  route_table_ids = [ aws_route_table.private_user_api.id, aws_route_table.private_post_api.id,  aws_route_table.public_api.id ]
  private_dns_enabled = false

	tags = {
		Name = "${var.SERVICE_NAME}-vpc-endpoint-for-s3"
	}
}

# endpoint for loging
resource "aws_vpc_endpoint" "portfolio_log" {
  vpc_id = aws_vpc.portfolio_vpc.id
  service_name = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type = "Interface"

  # subnet_ids = [ aws_subnet.private_api_1a.id, aws_subnet.private_api_1c.id, aws_subnet.public_api_lb_1a.id, aws_subnet.public_api_lb_1c.id ]
  subnet_ids = [ aws_subnet.private_user_api_1a.id, aws_subnet.private_user_api_1c.id ]
  security_group_ids = [
    aws_security_group.private_link.id
  ]
  private_dns_enabled = true

	tags = {
		Name = "${var.SERVICE_NAME}-vpc-endpoint-for-cloudwatch-log"
	}
}

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
