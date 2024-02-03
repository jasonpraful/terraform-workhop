output "domain_name" {
  value = aws_cloudfront_distribution.cf_distribution.domain_name

}

output "cf_distribution_id" {
  value = aws_cloudfront_distribution.cf_distribution.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.frontend_bucket.id
}
