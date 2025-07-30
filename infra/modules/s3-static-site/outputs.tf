output "website_url" {
  value = "http://${aws_s3_bucket.static_site.website_endpoint}"
}
