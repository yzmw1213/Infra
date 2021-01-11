# front ALB アクセスログバケットの作成
resource "aws_s3_bucket" "portfolio_access_logs_dev" {
  bucket = "portfolio-access-log-dev"
  acl    = "private"

  versioning {
      enabled = true
  }

  lifecycle_rule {
    prefix  = "config/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.portfolio_access_logs_dev.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.portfolio_access_logs_dev.id}",
      "arn:aws:s3:::${aws_s3_bucket.portfolio_access_logs_dev.id}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}
