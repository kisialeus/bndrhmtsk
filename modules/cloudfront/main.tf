resource "aws_s3_bucket" "cf_s3_bucket" {
  bucket = var.s3_bucket_name
  tags = var.tags
}

resource "aws_s3_bucket_policy" "cf_s3_bucket_policy" {
  bucket = aws_s3_bucket.cf_s3_bucket.id
  policy = var.enable_private_access ? data.aws_iam_policy_document.s3_bucket_policy_private_access[0].json : data.aws_iam_policy_document.s3_bucket_policy.json

}

resource "aws_s3_bucket_acl" "cf_s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.example]
  bucket = aws_s3_bucket.cf_s3_bucket.id
  acl    = "private"

}
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.cf_s3_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "access" {
    bucket = aws_s3_bucket.cf_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identify-${var.s3_bucket_name}"
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      ]
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy_private_access" {
  count = length(data.aws_iam_user.s3_user)
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      ]
    }
  }
 statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = [
        data.aws_iam_user.s3_user[count.index].arn
      ]
    }
  }
}


data "aws_iam_user" "s3_user" {
  count = var.enable_private_access == true ? 1 : 0
  user_name =  "${var.application}-s3-user"
}



resource "aws_cloudfront_distribution" "distribution" {

  origin {
    domain_name = aws_s3_bucket.cf_s3_bucket.bucket_domain_name
    origin_id   = "s3-${aws_s3_bucket.cf_s3_bucket.bucket}"

   s3_origin_config {
     origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
   }
  }

  dynamic "origin" {
    for_each = var.enable_lambda_edge ? toset(["empty-origin"]) : []
    content {
      domain_name = "${origin.value}-${var.domain_name}"
      origin_id = origin.value
      custom_origin_config {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "match-viewer"
        origin_read_timeout      = 30
        origin_ssl_protocols     = [
            "SSLv3",
            "TLSv1",
            "TLSv1.1",
            "TLSv1.2",
          ]
      }
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${aws_s3_bucket.cf_s3_bucket.bucket}"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

  }
  


  custom_error_response {
    error_caching_min_ttl = 10
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }

 custom_error_response {
    error_caching_min_ttl = 10
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
    acm_certificate_arn = var.aws_acm_certificate_arn
  }

    tags = var.tags

}

resource "aws_ssm_parameter" "cloudfront_distribution" {
  name  = "${var.application}/cloudfront/distribution-id"
  type  = "String"
  value = aws_cloudfront_distribution.distribution.id
}
