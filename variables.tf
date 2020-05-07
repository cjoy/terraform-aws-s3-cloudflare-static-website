variable "bucket_name" {
	description = "This corresponds to a unique bucket name in which you want to store your site contents. It is normally convention to use the domain name as the bucket name (eg. example.com)."
	type        = string
}
variable "index_document" {
	description = "This corresponds to the default index document. (Defaults to index.html)"
	type        = string
	default 		= "index.html"
}
variable "error_document" {
	description = "This corresponds to the default error document. (Defaults to error.html)"
	type        = string
	default 		= "error.html"
}
variable "domain_name" {
	description = "This is the domain name you want to use to point your website. (eg. example.com, www.example.com etc)"
	type        = string
}
variable "tags" {
	description = "Tags you would like to apply across AWS resources"
	type = map(string)
	default = {}
}

variable "aws_access_key" {
	description = "This is the AWS access key. You can retrieve this by creating a new IAM user, with programmatic access."
	type        = string
}
variable "aws_secret" {
	description = "This is the AWS secret key. You can retrieve this by creating a new IAM user, with programmatic access."
	type        = string
}
variable "aws_region" {
	description = "This corresponds to the AWS region you want to host your S3 bucket. Eg. us-east-1, us-east-2, us-west-1, us-west-2 ... (Defaults to us-east-2)"
	type        = string
	default     = "us-east-2" 
}

variable "cloudflare_token" {
  description = "This is your Cloudflare token. You can generate in the cloudflare dashboard, under your profile settings."
  type        = string
}
variable "cloudflare_zone_id" {
  description = "The DNS zone ID in which add the record. You can get this from the domain view in the cloudflare dashboard."
  type        = string
}


