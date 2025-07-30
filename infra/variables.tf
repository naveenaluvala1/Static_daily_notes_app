variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for static site"
  type        = string
  default     = "daily-notes-bucket-123"
}
