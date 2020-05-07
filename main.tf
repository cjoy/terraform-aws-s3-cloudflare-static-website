provider "aws" {
  version = "~> 2.0"
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret
}

provider "aws" {
  version = "~> 2.0"
  alias = "virginia"
  region = "us-east-1"
}

provider "cloudflare" {
  version   = "~> 2.0"
  api_token = var.cloudflare_token
}

/* ======= Steps ======= */

/* 1. Create bucket for storing static website files */
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "public-read"
  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "PublicReadGetObject",
			"Effect": "Allow",
			"Principal": "*",
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::${var.bucket_name}/*"
		}
	]
}
POLICY
  website {
    index_document = var.index_document
    error_document = var.error_document
  }

  tags = var.tags
}


/* 2. Provision ACM certificate to verify domains */
resource "aws_acm_certificate" "cert" {
  provider = aws.virginia
  domain_name = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  
	tags = var.tags
}


/* 3. Provision ACM validation record via cloudflare */
resource "cloudflare_record" "acm" {
  depends_on = [aws_acm_certificate.cert]

  zone_id = var.cloudflare_zone_id
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  value   = aws_acm_certificate.cert.domain_validation_options.0.resource_record_value
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
}

/* 3. ACM Validation after adding DNS record */
resource "aws_acm_certificate_validation" "cert" {
  provider = aws.virginia
  depends_on = [cloudflare_record.acm, aws_acm_certificate.cert]

  certificate_arn = aws_acm_certificate.cert.arn
}

/* 4. Provision cloudfront distribution infront of S3 bucket */
resource "aws_cloudfront_distribution" "dist" {
  depends_on = [aws_s3_bucket.bucket, aws_acm_certificate_validation.cert]

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document

  aliases = [var.domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method = "sni-only"
  }

	tags = var.tags
}

/* 5. Add CNAME record to Cloudflare DNS which points to the newly created cloudfront distribution */
resource "cloudflare_record" "cname" {
  depends_on = [aws_cloudfront_distribution.dist]

  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  value   = aws_cloudfront_distribution.dist.domain_name
  type    = "CNAME"
}
