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
