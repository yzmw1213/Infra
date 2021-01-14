# VPCエンドポイントにアタッチするセキュリティグループ
resource "aws_security_group" "private-link" {
  vpc_id = aws_vpc.portfolio-vpc-dev.id
  name = "${var.SERVICE_NAME}-private-link-endpoint-dev"
  description = "${var.SERVICE_NAME} security group for vpc endpoint"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ aws_subnet.private_api_1a.cidr_block,aws_subnet.private_api_1c.cidr_block ]
  }
}
