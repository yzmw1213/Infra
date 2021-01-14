# System Manager

resource "aws_ssm_parameter" "USER_DB_NAME_DEV" {
  name  = "USER_DB_NAME"
  type  = "String"
  value = aws_db_instance.rds_userDB-dev.name
}

resource "aws_ssm_parameter" "USER_DB_PASSWORD_DEV" {
  name  = "USER_DB_PASSWORD"
  type  = "String"
  value = aws_db_instance.rds_userDB-dev.password
}

resource "aws_ssm_parameter" "USER_DB_USER_DEV" {
  name  = "USER_DB_USER"
  type  = "String"
  value = aws_db_instance.rds_userDB-dev.username
}

resource "aws_ssm_parameter" "USER_DB_ADRESS_DEV" {
  name  = "USER_DB_ADRESS"
  type  = "String"
  value = aws_db_instance.rds_userDB-dev.endpoint
}
