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

variable "API_LOAD_BALANCER_NAME" {
  description = "Name of Load Balancer for API"
}

variable "SERVICE_NAME" {}
variable "FRONTEND_NAME" {}
variable "USERSERVICE_NAME" {}

variable "FRONTPROXY_NAME" {}

variable "FRONTEND_TASK_DEFINITION_NAME" {
  description = "Name of ECS Cluster Task definition of Frontend"
}

variable "FRONTPROXY_TASK_DEFINITION_NAME" {
  description = "Name of ECS Cluster Task definition of FrontProxy"
}

variable "USERSERVICE_TASK_DEFINITION_NAME" {
  description = "Name of ECS Cluster Task definition of UserService"
}

variable "USER_RDS_NAME" {}
variable "USER_RDS_USERNAME" {}
variable "USER_RDS_PASSWORD" {}