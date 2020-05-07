# Static Website (S3, CloudFront & Cloudflare) 
This terraform module provisions AWS & CloudFlare resources allowing you to deploy a static websites using S3 (static file storage), CloudFront (CDN) & CloudFlare (DNS Management).

This module should be used inconjuction with your prefered continuous integration service (CircleCI, Github Actions etc). You can use this module to provision the required resources and should rely on your CI process to build and sync to S3. 

## What it does
**Step 1**: Create a S3 bucket used to store static website files.

**Step 2**: Provision an ACM certificate to verify you domain.

**Step 3**: Provision ACM validation record via cloudflare. This is so that ACM can validate you own the domain you specified.

**Step 4**: Test ACM Validation after adding DNS validation record.

**Step 5**: Provision cloudfront distribution to serve you files out of the S3 bucket.

**Step 6**: Add CNAME record to Cloudflare DNS which points to the newly created cloudfront distribution.

## Example Usage
```terraform
module "static-web-hosting" {
    source = "cjoy/s3-cloudflare-static-website/aws"

    bucket_name = "example-website-bucket"
    index_document = "index.html"
    error_document =  "error.html"
    domain_name = "example.com"

    aws_access_key = "ASYDD3ABRDVP34UaDSFX4"
    aws_secret = "FQhwfbErYFSFD3fdsDF67gpZXcUVycRYRTPHha"
    aws_region = "us-east-2"

    cloudflare_token = "C6Z1Da-yp9Cdshj0ymaHZvK0ujmWnEAELehi0KlL"
    cloudflare_zone_id = "4ab79b65343sdf44dca2943d2345d9dbf0d"
} 
```

## Arguments
| Argument | Type | Description |
|----------|------|-------------|
| **bucket_name** | `string` | This corresponds to a unique bucket name in which you want to store your site contents. It is normally convention to use the domain name as the bucket name (eg. example.com). |
| **index_document** | `string` | This corresponds to the default index document. (Defaults to index.html) |
| **error_document** | `string` | This corresponds to the default error document. (Defaults to error.html) |
| **domain_name** | `string` | This is the domain name you want to use to point your website. (eg. example.com, www.example.com etc) |
| **tags** | `map(string)` | Tags you would like to apply across AWS resources |
| **aws_access_key** | `string` | This is the AWS access key. You can retrieve this by creating a new IAM user, with programmatic access. |
| **aws_secret** | `string` | This is the AWS secret key. You can retrieve this by creating a new IAM user, with programmatic access. |
| **aws_region** | `string` | This corresponds to the AWS region you want to host your S3 bucket. Eg. us-east-1, us-east-2, us-west-1, us-west-2 ... (Defaults to us-east-2) |
| **cloudflare_token** | `string` | This is your Cloudflare token. You can generate in the cloudflare dashboard, under your profile settings. |
| **cloudflare_zone_id** | `string` | The DNS zone ID in which add the record. You can get this from the domain view in the cloudflare dashboard. |



## Example Plan
```zsh
$ terraform plan    
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_acm_certificate.cert will be created
  + resource "aws_acm_certificate" "cert" {
      + arn                       = (known after apply)
      + domain_name               = "example.xyz"
      + domain_validation_options = (known after apply)
      + id                        = (known after apply)
      + subject_alternative_names = (known after apply)
      + validation_emails         = (known after apply)
      + validation_method         = "DNS"
    }

  # aws_acm_certificate_validation.cert will be created
  + resource "aws_acm_certificate_validation" "cert" {
      + certificate_arn = (known after apply)
      + id              = (known after apply)
    }

  # aws_cloudfront_distribution.dist will be created
  + resource "aws_cloudfront_distribution" "dist" {
      + active_trusted_signers         = (known after apply)
      + aliases                        = [
          + "example.xyz",
        ]
      + arn                            = (known after apply)
      + caller_reference               = (known after apply)
      + default_root_object            = "index.html"
      + domain_name                    = (known after apply)
      + enabled                        = true
      + etag                           = (known after apply)
      + hosted_zone_id                 = (known after apply)
      + http_version                   = "http2"
      + id                             = (known after apply)
      + in_progress_validation_batches = (known after apply)
      + is_ipv6_enabled                = true
      + last_modified_time             = (known after apply)
      + price_class                    = "PriceClass_All"
      + retain_on_delete               = false
      + status                         = (known after apply)
      + wait_for_deployment            = true

      + default_cache_behavior {
          + allowed_methods        = [
              + "DELETE",
              + "GET",
              + "HEAD",
              + "OPTIONS",
              + "PATCH",
              + "POST",
              + "PUT",
            ]
          + cached_methods         = [
              + "GET",
              + "HEAD",
            ]
          + compress               = false
          + default_ttl            = 3600
          + max_ttl                = 86400
          + min_ttl                = 0
          + target_origin_id       = "S3-example-website-bucket"
          + viewer_protocol_policy = "allow-all"

          + forwarded_values {
              + query_string = false

              + cookies {
                  + forward = "none"
                }
            }
        }

      + origin {
          + domain_name = (known after apply)
          + origin_id   = "S3-example-website-bucket"
        }

      + restrictions {
          + geo_restriction {
              + restriction_type = "none"
            }
        }

      + viewer_certificate {
          + acm_certificate_arn      = (known after apply)
          + minimum_protocol_version = "TLSv1"
          + ssl_support_method       = "sni-only"
        }
    }

  # aws_s3_bucket.bucket will be created
  + resource "aws_s3_bucket" "bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "public-read"
      + arn                         = (known after apply)
      + bucket                      = "example-website-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:GetObject"
                      + Effect    = "Allow"
                      + Principal = "*"
                      + Resource  = "arn:aws:s3:::example-website-bucket/*"
                      + Sid       = "PublicReadGetObject"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }

      + website {
          + error_document = "error.html"
          + index_document = "index.html"
        }
    }

  # cloudflare_record.acm will be created
  + resource "cloudflare_record" "acm" {
      + created_on  = (known after apply)
      + hostname    = (known after apply)
      + id          = (known after apply)
      + metadata    = (known after apply)
      + modified_on = (known after apply)
      + name        = (known after apply)
      + proxiable   = (known after apply)
      + proxied     = false
      + ttl         = (known after apply)
      + type        = (known after apply)
      + value       = (known after apply)
      + zone_id     = "4ab79b65343sdf44dca2943d2345d9dbf0d"
    }

  # cloudflare_record.cname will be created
  + resource "cloudflare_record" "cname" {
      + created_on  = (known after apply)
      + hostname    = (known after apply)
      + id          = (known after apply)
      + metadata    = (known after apply)
      + modified_on = (known after apply)
      + name        = "example.xyz"
      + proxiable   = (known after apply)
      + proxied     = false
      + ttl         = (known after apply)
      + type        = "CNAME"
      + value       = (known after apply)
      + zone_id     = "4ab79b65343sdf44dca2943d2345d9dbf0d"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```