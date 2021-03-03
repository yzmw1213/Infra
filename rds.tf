resource "aws_db_subnet_group" "user_rds_subnet_group" {
  name = "user-rds-subnet-group"
  description = "RDS subnet group for User DB"
  subnet_ids = [aws_subnet.private_user_db_1a.id, aws_subnet.private_user_db_1c.id]
}

resource "aws_db_subnet_group" "post_rds_subnet_group" {
  name = "post-rds-subnet-group"
  description = "RDS subnet group for Post DB"
  subnet_ids = [aws_subnet.private_post_db_1a.id, aws_subnet.private_post_db_1c.id]
}

# ユーザーサービス RDS
resource "aws_db_instance" "rds_userDB" {
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.user_rds_subnet_group.name
  parameter_group_name = "${var.SERVICE_NAME}-mysql-pg"
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  identifier = "rds-userdb-portfolio"
  instance_class       = "db.t2.micro"
  name                 = var.USER_RDS_NAME
  username             = var.USER_RDS_USERNAME
  password             = var.USER_RDS_PASSWORD
  vpc_security_group_ids  = [aws_security_group.userDB.id]
  multi_az = false
  final_snapshot_identifier = "rds-user-mysql-instance-backup"
  skip_final_snapshot = true
  port = 3306
}

# 投稿サービス RDS
resource "aws_db_instance" "rds_postDB" {
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.post_rds_subnet_group.name
  parameter_group_name = "${var.SERVICE_NAME}-mysql-pg"
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  identifier = "rds-postdb-portfolio"
  instance_class       = "db.t2.micro"
  name                 = var.POST_RDS_NAME
  username             = var.POST_RDS_USERNAME
  password             = var.POST_RDS_PASSWORD
  vpc_security_group_ids  = [aws_security_group.postDB.id]
  multi_az = false
  final_snapshot_identifier = "rds-post-mysql-instance-backup"
  skip_final_snapshot = true
  port = 3306
}

resource "aws_security_group" "userDB" {
	name        = "${var.SERVICE_NAME}-rds"
	description = "${var.SERVICE_NAME} security group for rds"

	vpc_id = aws_vpc.portfolio_vpc.id

  egress {
	  from_port   = 0
	  to_port     = 0
	  protocol    = "-1"
	  cidr_blocks = [ aws_vpc.portfolio_vpc.cidr_block ]
  }

  tags = {
	  Name = "${var.USERSERVICE_NAME}-rds-sg"
  }
}

resource "aws_security_group_rule" "ec2_mysql_in_connect" {
  security_group_id = aws_security_group.userDB.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.ec2_public_1a.cidr_block ]
  from_port = aws_db_instance.rds_userDB.port
  to_port = aws_db_instance.rds_userDB.port
  protocol = "tcp"
}

resource "aws_security_group_rule" "rds_connect_from_user_ecs" {
  security_group_id = aws_security_group.userDB.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.private_user_api_1a.cidr_block, aws_subnet.private_user_api_1c.cidr_block ]
  from_port = aws_db_instance.rds_userDB.port
  to_port = aws_db_instance.rds_userDB.port
  protocol = "tcp"
}

resource "aws_security_group" "postDB" {
	name        = "${var.SERVICE_NAME}-post-rds"
	description = "${var.SERVICE_NAME} security group for rds"

	vpc_id = aws_vpc.portfolio_vpc.id

  egress {
	  from_port   = 0
	  to_port     = 0
	  protocol    = "-1"
	  cidr_blocks = [ aws_vpc.portfolio_vpc.cidr_block ]
  }

  tags = {
	  Name = "${var.POSTSERVICE_NAME}-rds-sg"
  }
}

resource "aws_security_group_rule" "rds_connect_from_post_ecs" {
  security_group_id = aws_security_group.postDB.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.private_post_api_1a.cidr_block, aws_subnet.private_post_api_1c.cidr_block ]
  from_port = aws_db_instance.rds_postDB.port
  to_port = aws_db_instance.rds_postDB.port
  protocol = "tcp"
}

resource "aws_security_group_rule" "post_rds_connect_from_ec2" {
  security_group_id = aws_security_group.postDB.id
  type = "ingress"
  cidr_blocks     = [ aws_subnet.ec2_public_1a.cidr_block ]
  from_port = aws_db_instance.rds_postDB.port
  to_port = aws_db_instance.rds_postDB.port
  protocol = "tcp"
}
