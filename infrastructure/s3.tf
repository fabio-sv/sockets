resource "aws_s3_bucket" "main" {
  bucket        = "${data.aws_caller_identity.current.account_id}-serverless-chat"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = templatefile("./policies/bucket.json", {
    bucket_arn     = aws_s3_bucket.main.arn
    cloudfront_arn = aws_cloudfront_distribution.main.arn
  })
}