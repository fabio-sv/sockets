resource "aws_s3_bucket" "ui" {
  bucket = "apigw-sockets-svelte-ui"
}

resource "aws_s3_bucket_public_access_block" "ui_access_block" {
  bucket = aws_s3_bucket.ui.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "ui_bucket_cloudfront_policy" {
  bucket = aws_s3_bucket.ui.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:GetObject"
        Effect = "Allow"
        Sid    = "AllowCloudFrontServicePrincipal"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Resource = "${aws_s3_bucket.ui.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" : aws_cloudfront_distribution.ui-distribution.arn
          }
        }
      }
    ]
  })
}
