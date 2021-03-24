# front ALB アクセスログバケットの作成
resource "aws_s3_bucket" "portfolio_access_logs" {
  bucket = "portfolio-front-access-log"
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

# 投稿への添付画像を格納するバケット
resource "aws_s3_bucket" "portfolio_post_image" {
  bucket = "portfolio-post-image"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://${aws_route53_record.hostzone_record.name}"]
    expose_headers  = []
    max_age_seconds = 3000
  }

  versioning {
      enabled = false
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
  bucket = aws_s3_bucket.portfolio_access_logs.id
  policy = data.aws_iam_policy_document.alb_log.json
}

resource "aws_s3_bucket_policy" "post_image" {
  bucket = aws_s3_bucket.portfolio_post_image.id
  policy = data.aws_iam_policy_document.post_image.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.portfolio_access_logs.id}",
      "arn:aws:s3:::${aws_s3_bucket.portfolio_access_logs.id}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}

data "aws_iam_policy_document" "post_image" {
  statement {
    sid = "Allow-Public-Access-To-Bucket"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.portfolio_post_image.id}",
      "arn:aws:s3:::${aws_s3_bucket.portfolio_post_image.id}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}
