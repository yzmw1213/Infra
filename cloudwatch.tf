# cloudwatch log groups
resource "aws_cloudwatch_log_group" "frontend_ecstask_log_group" {
  name = "frontend-cluster-log-group"
}

resource "aws_cloudwatch_log_group" "frontproxy_ecstask_log_group" {
  name = "frontproxy-cluster-log-group"
}

resource "aws_cloudwatch_log_group" "userservice_ecstask_log_group" {
  name = "userservice-cluster-log-group"
}

resource "aws_cloudwatch_log_group" "postservice_ecstask_log_group" {
  name = "postservice-cluster-log-group"
}
