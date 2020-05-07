variable "bucket_name" {
	description = "This corresponds to a unique bucket name in which you want to store your site contents. It is normally convention to use the domain name as the bucket name (eg. example.com)."
	type        = string
}
variable "tags" {
	description = "Tags you would like to apply across AWS resources."
	type = map(string)
	default = {}
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
variable "cloudflare_zone_id" {
  description = "The DNS zone ID in which add the record. You can get this from the domain view in the cloudflare dashboard."
  type        = string
}


