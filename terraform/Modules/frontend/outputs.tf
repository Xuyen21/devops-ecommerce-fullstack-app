output "certificate" {
  value = aws_acm_certificate.cert
  sensitive = true
}

output "certificate_validation_record" {
  value     = aws_route53_record.cert_validation_add_CNAME_record
  sensitive = true
}

output "certificate_validation_fqdns" {
  value     = aws_acm_certificate_validation.cert_validation
  sensitive = true
}