provider "aws" {
  region = var.region
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "infragenie_bucket" {
  bucket        = "infragenie-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "infragenie-bucket"
    ManagedBy = "InfraGenie"
  }
}

