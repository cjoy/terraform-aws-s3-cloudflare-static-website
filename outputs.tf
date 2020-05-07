output "aws_cloudfront" {
	description = "Attributes from aws_cloudfront_distribution (https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html)"
  value = aws_cloudfront_distribution.dist
}

output "aws_s3" {
	description = "Attributes from aws_s3_bucket (https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)"
  value = aws_s3_bucket.bucket
}

output "aws_acm" {
	description = "Attributes from aws_acm_certificate (https://www.terraform.io/docs/providers/aws/r/acm_certificate.html)"
  value = aws_acm_certificate.cert
}
