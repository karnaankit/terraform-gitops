provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "ankit-gitops-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state_ankit_gitops"
  }
}

resource "aws_s3_bucket_versioning" "dist_bucket_versioning" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "tf_backend_bucket_object_lock" {
  depends_on          = [aws_s3_bucket_versioning.dist_bucket_versioning]
  bucket              = aws_s3_bucket.default.id
  object_lock_enabled = "Enabled"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend_bucket_sse" {
  bucket = aws_s3_bucket.default.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "default" {
  bucket = "${var.bucket}-${terraform.workspace}"
  tags = {
    Name = var.bucket
  }
}
