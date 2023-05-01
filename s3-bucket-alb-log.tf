data "aws_elb_service_account" "default" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${module.this.id}-lb-logs"
  force_destroy = var.log_bucket_force_destroy

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-lb-logs"
    },
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-encryption" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "lb_logs_access_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.default.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "lb_logs_access_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.lb_logs_access_policy_document.json
}

resource "aws_s3_bucket_lifecycle_configuration" "datadog_log_archive" {
  bucket = aws_s3_bucket.alb_logs.id
  status = "Enabled"
  
  rule {
    id = "glacier-one-year-old"

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}
