output "internal_service_dns" {
  value = aws_route53_zone.private_zone
}
output "public_service_dns" {
  value = "${var.public_url_name}.${var.hosted_zone}"
}
