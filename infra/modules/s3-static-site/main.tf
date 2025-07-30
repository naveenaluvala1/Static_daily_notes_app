resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "s3:GetObject",
      Resource = "${aws_s3_bucket.static_site.arn}/*"
    }]
  })
}

resource "aws_s3_object" "site_files" {
  for_each = fileset("${path.module}/../../../app", "**/*.*")

  bucket = aws_s3_bucket.static_site.id
  key    = each.value
  source = "${path.module}/../../../app/${each.value}"
  etag   = filemd5("${path.module}/../../../app/${each.value}")
  content_type = lookup({
    "html" = "text/html"
    "js"   = "application/javascript"
    "json" = "application/json"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}
