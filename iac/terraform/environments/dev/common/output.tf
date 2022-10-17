output "vpc_name" {
  value = "${local.name_prefix}-vpc"
}

output "elb_dns_domain" {
  value = local.elb_created ? aws_lb.this[0].dns_name : null
}

output "cloudfront_domain" {
  value = var.cloudfront_created ? aws_cloudfront_distribution.this.domain_name : null
}

output "s3_static_bucket" {
  value = aws_s3_bucket.this.id
}