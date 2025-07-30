provider "aws" {
  region = var.region
}

module "s3_static_site" {
  source      = "./modules/s3-static-site"
  bucket_name = var.bucket_name
  region      = var.region
}
