resource "aws_s3_bucket" "static_site" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Environment = "dev"
  }
}

resource "aws_s3_bucket_website_configuration" "static_site_website" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

#  Secure public access block: allows policies but blocks ACLs
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true               # block ACLs
  block_public_policy     = false              # allow bucket policy
  ignore_public_acls      = true
  restrict_public_buckets = false              # allow bucket policy to take effect
}

# Secure public read-only policy
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })

  #  Make sure public access block is applied before this
  depends_on = [aws_s3_bucket_public_access_block.public]
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
