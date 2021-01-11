variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "ap-northeast-1"
}

variable "aws_resource_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources"
}

variable "FRONT_LOAD_BALANCER_NAME" {
  description = "Name of Load Balancer for Front"
}

variable "SERVICE_NAME" {}
variable "FRONTEND_NAME" {}

variable "FRONTEND_TASK_DEFINITION_NAME" {
  description = "Name of ECS Cluster Task definition of Frontend"
}
