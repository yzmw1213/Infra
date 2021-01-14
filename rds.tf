resource "aws_db_subnet_group" "db-subnet-group-dev" {
  name = "mysql-subnet"
  description = "RDS subnet group for User DB"
  subnet_ids = [aws_subnet.private_db_1a.id, aws_subnet.private_db_1c.id]
}

resource "aws_db_instance" "rds_userDB-dev" {
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.db-subnet-group-dev.name
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  identifier = "rds-userdb-portfolio-dev"
  instance_class       = "db.t2.micro"
  name                 = var.USER_RDS_NAME
  username             = var.USER_RDS_USERNAME
  password             = var.USER_RDS_PASSWORD
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids  = [aws_security_group.userDB.id]
  multi_az = false
  final_snapshot_identifier = "rds-user-mysql-instance-backup"
  skip_final_snapshot = true
  port = 3306
}

resource "aws_security_group" "userDB" {
	name        = "${var.SERVICE_NAME}-rds"
	description = "${var.SERVICE_NAME} security group for rds"

	vpc_id = aws_vpc.portfolio-vpc-dev.id

  egress {
	  from_port   = 0
	  to_port     = 0
	  protocol    = "-1"
	  cidr_blocks = [ aws_vpc.portfolio-vpc-dev.cidr_block ]
  }

  tags = {
	  Name = "${var.SERVICE_NAME}-rds-sg"
  }
}

resource "aws_security_group_rule" "ec2_mysql_in_connect" {
  security_group_id = aws_security_group.userDB.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.ec2_public_1a.cidr_block ]
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
}

resource "aws_security_group_rule" "ecs_mysql_in_connect" {
  security_group_id = aws_security_group.userDB.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.private_api_1a.cidr_block, aws_subnet.private_api_1c.cidr_block ]
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
}