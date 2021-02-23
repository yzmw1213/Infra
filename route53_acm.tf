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
resource "aws_route53_record" "hostzone_record_front" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "front.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.front_alb.dns_name
    zone_id                = aws_lb.front_alb.zone_id
    evaluate_target_health = true
  }
}

# api側のelbのDNSをドメイン登録
resource "aws_route53_record" "hostzone_record_api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.api_alb.dns_name
    zone_id                = aws_lb.api_alb.zone_id
    evaluate_target_health = true
  }
}
