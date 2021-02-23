locals {
  # The name of the ECS cluster to be created
  aws_ecs_cluster_name = "${var.aws_resource_prefix}-cluster"

  # The name of the ECR frontend image repository to be created
  aws_ecr_frontend_repository_name = "${var.aws_resource_prefix}-frontend-repo"

  # The name of the ECR postservice image repository to be created
  aws_ecr_postservice_repository_name = "${var.aws_resource_prefix}-postservice-repo"

  # The name of the ECR userservice image repository to be created
  aws_ecr_userservice_repository_name = "${var.aws_resource_prefix}-userservice-repo"
}
