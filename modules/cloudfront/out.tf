output "cloudfront_zone_id" {value = aws_cloudfront_distribution.distribution.hosted_zone_id}
output "cloudfront_original_domain" {value = aws_cloudfront_distribution.distribution.domain_name}
output "cloudfront_alternate_domain" {value = var.domain_name}
output "cloudfront_certificate" {value = var.aws_acm_certificate_arn}
