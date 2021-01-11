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


# # IGW
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

# # Association
resource "aws_route_table_association" "public_1a" {
	subnet_id      = aws_subnet.public_1a.id
	route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
	subnet_id      = aws_subnet.public_1c.id
	route_table_id = aws_route_table.public.id
}
