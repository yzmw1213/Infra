resource "aws_ecs_cluster" "portfolio-cluster-dev" {
  name = "${local.aws_ecs_cluster_name}-dev"
}
