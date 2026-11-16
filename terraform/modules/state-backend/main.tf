resource "aws_s3_bucket" "eks" {
  bucket = var.s3-backend-bucket

  tags = merge(var.tags, {
    Name = "${var.name} - s3"
  })
}

resource "aws_s3_bucket_public_access_block" "private-eks" {
  bucket = aws_s3_bucket.eks.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}