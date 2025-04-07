# Add an S3 Bucket for Static Files

# Use Case:
# Store static assets: images, JavaScript, CSS, backups, etc.
# Later, you can connect this to your app or even serve it via CloudFront.

resource "aws_s3_bucket" "tf-static_assets" {
  bucket        = "${var.Project_Name}-static-assets"
  force_destroy = true # Set to false in production

  tags = {
    Name        = "${var.Project_Name}-static-assets"
    Environment = var.environment
  }
}

# Optional - Enable Public Read (only if needed)
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.tf-static_assets.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.tf-static_assets.arn}/*"
      }
    ]
  })
}

# Recommended: Block Public Access by Default
resource "aws_s3_bucket_public_access_block" "tf-default" {
  bucket = aws_s3_bucket.tf-static_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional: Add Bucket Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf-static_assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Grant CloudFront Access to S3
resource "aws_s3_bucket_policy" "cf_access" {
  bucket = aws_s3_bucket.tf-static_assets.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly",
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.tf-static_assets.arn}/*"
      }
    ]
  })
}
