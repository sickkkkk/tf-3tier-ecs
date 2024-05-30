resource "aws_acm_certificate" "wildcard_dev" {
  domain_name       = "*.dev.uncalled.${var.base_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "wildcard-${local.short_region}-${local.env_short_names[var.env]}"
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_dev.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.aws_route53_zone.decartel_root.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "validation_wildcard_dev" {
  certificate_arn         = aws_acm_certificate.wildcard_dev.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}