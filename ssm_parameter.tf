# System Manager
resource "aws_ssm_parameter" "USER_DB_NAME" {
  name  = "USER_DB_NAME"
  type  = "String"
  value = aws_db_instance.rds_userDB.name
}

resource "aws_ssm_parameter" "USER_DB_PASSWORD" {
  name  = "USER_DB_PASSWORD"
  type  = "String"
  value = aws_db_instance.rds_userDB.password
}

resource "aws_ssm_parameter" "USER_DB_USER" {
  name  = "USER_DB_USER"
  type  = "String"
  value = aws_db_instance.rds_userDB.username
}

resource "aws_ssm_parameter" "USER_DB_ADRESS" {
  name  = "USER_DB_ADRESS"
  type  = "String"
  value = aws_db_instance.rds_userDB.endpoint
}

resource "aws_ssm_parameter" "POST_DB_NAME" {
  name  = "POST_DB_NAME"
  type  = "String"
  value = aws_db_instance.rds_postDB.name
}

resource "aws_ssm_parameter" "POST_DB_PASSWORD" {
  name  = "POST_DB_PASSWORD"
  type  = "String"
  value = aws_db_instance.rds_postDB.password
}

resource "aws_ssm_parameter" "POST_DB_USER" {
  name  = "POST_DB_USER"
  type  = "String"
  value = aws_db_instance.rds_postDB.username
}

resource "aws_ssm_parameter" "POST_DB_ADRESS" {
  name  = "POST_DB_ADRESS"
  type  = "String"
  value = aws_db_instance.rds_postDB.endpoint
}
