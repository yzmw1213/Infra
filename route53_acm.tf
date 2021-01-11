variable "domain" {
  description = "domain maneged On Route53"
  type = string
}

data "aws_route53_zone"  "main" {
  name = var.domain
  private_zone = false
}

# data "aws_acm_certificate" "issued" {
#   domain   = var.domain
# }
