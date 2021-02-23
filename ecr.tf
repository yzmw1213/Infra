resource "aws_ecr_repository" "frontend" {
  name = local.aws_ecr_frontend_repository_name
}

resource "aws_ecr_repository" "postservice" {
  name = local.aws_ecr_postservice_repository_name
}

resource "aws_ecr_repository" "userservice" {
  name = local.aws_ecr_userservice_repository_name
}

resource "aws_ecr_repository" "frontproxy" {
  name = "${local.aws_ecr_frontend_repository_name}-proxy"
}

resource "aws_ecr_repository" "postproxy" {
  name = "${local.aws_ecr_postservice_repository_name}-proxy"
}

resource "aws_ecr_repository" "userproxy" {
  name = "${local.aws_ecr_userservice_repository_name}-proxy"
}
