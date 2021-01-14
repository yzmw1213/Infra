# # Internet VPC
resource "aws_vpc" "portfolio-vpc-dev" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false

  tags =  {
    Name = "portfolio-vpc-dev"
  }
}

resource "aws_subnet" "ec2_public_1a" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.101.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-ec2-public-1a"
  }
}

resource "aws_subnet" "ec2_public_1c" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.102.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-ec2-public-1c"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-public-1c"
  }
}

resource "aws_subnet" "private_api_1a" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.SERVICE_NAME}-private-1a"
  }
}

resource "aws_subnet" "private_api_1c" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.SERVICE_NAME}-private-1c"
  }
}

resource "aws_subnet" "private_db_1a" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.20.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.USER_RDS_NAME}-private-1a"
  }
}

resource "aws_subnet" "private_db_1c" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  cidr_block = "10.0.21.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.USER_RDS_NAME}-private-1c"
  }
}

# IGW
resource "aws_internet_gateway" "portfolio-igw-dev" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  
  tags = {
    Part = "${var.SERVICE_NAME}-gw"
  }
}

# Route Table (Public)
resource "aws_route_table" "public" {
	vpc_id = aws_vpc.portfolio-vpc-dev.id

	tags = {
		Name = "${var.SERVICE_NAME}-public"
	}
}

# Route
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.portfolio-igw-dev.id
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

# Route Table (Private)
resource "aws_route_table" "private-api" {
	vpc_id = aws_vpc.portfolio-vpc-dev.id

	tags = {
		Name = "${var.SERVICE_NAME}-private"
	}
}

# Association
resource "aws_route_table_association" "private_1a" {
	subnet_id      = aws_subnet.private_api_1a.id
	route_table_id = aws_route_table.private-api.id
}

resource "aws_route_table_association" "private_1c" {
	subnet_id      = aws_subnet.private_api_1c.id
	route_table_id = aws_route_table.private-api.id
}

# endpoint for docker pull
resource "aws_vpc_endpoint" "portfolio-ecr-dkr-dev" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  service_name = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [ aws_subnet.private_api_1a.id, aws_subnet.private_api_1c.id ]
  security_group_ids = [
    aws_security_group.private-link.id
  ]
  private_dns_enabled = true

	tags = {
		Name = "${var.SERVICE_NAME}-vpc-endpoint-for-ecr-dkr-dev"
	}
}

# endpoint for docker pull
resource "aws_vpc_endpoint" "portfolio-ecr-s3-dev" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
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

  route_table_ids = [ aws_route_table.private-api.id, ]
  private_dns_enabled = false

	tags = {
		Name = "${var.SERVICE_NAME}-vpc-endpoint-for-s3-dev"
	}
}
