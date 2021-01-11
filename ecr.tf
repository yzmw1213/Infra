resource "aws_ecr_repository" "frontend-dev" {
  name = "${local.aws_ecr_frontend_repository_name}-dev"
}

resource "aws_ecr_repository" "postservice-dev" {
  name = "${local.aws_ecr_postservice_repository_name}-dev"
}

resource "aws_ecr_repository" "userservice-dev" {
  name = "${local.aws_ecr_userservice_repository_name}-dev"
}
