data "aws_route53_zone" "selected" {
  name = "devops-pro.me"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# add CNAME record to prove domain ownership
resource "aws_route53_record" "cert_validation_add_CNAME_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}


# add full qualified domain name (FQDN) for the certificate validation
# if this execution is successful -> certificated is issued
# if this execution fails -> certificate is not issued
# this resource is optional and it creates nothing, it only terraform code that make terraform wait until the status is ISSUED.

# cloudfront requires this issued certificate -> add this waiting is best practice 

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_add_CNAME_record : record.fqdn]
}

resource "aws_route53_record" "A" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = module.cloudfront_distribution.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront_distribution.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }

}


resource "aws_route53_record" "AAAA" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "AAAA"
  alias {
    name                   = module.cloudfront_distribution.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront_distribution.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}