variable "domain" {
  description = "domain maneged On Route53"
  type = string
}

data "aws_route53_zone"  "main" {
  name = var.domain
  private_zone = false
}

data "aws_acm_certificate" "issued" {
  domain   = var.domain
}

# front側のelbのDNSをドメイン登録
resource "aws_route53_record" "hostzone_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}
