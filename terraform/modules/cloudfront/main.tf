data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = var.sid
    effect = var.effect

    principals {
      type        = var.type
      identifiers = var.identifiers
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${var.bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

locals {
  s3_origin_id = "myS3Origin"
 # my_domain    = "mydomain.com"
}

#data "aws_acm_certificate" "my_domain" {
#  region   = "us-east-1"
 # domain   = "*.${local.my_domain}"
 # statuses = ["ISSUED"]
#}

# Free flat-rate plan doesn't support legacy forwarded_values/TTL settings, so use AWS managed policies
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "cors_s3_origin" {
  name = "Managed-CORS-S3Origin"
}

# Flat-rate pricing plans require a WAF web ACL on the distribution (CLOUDFRONT scope must be in us-east-1)
resource "aws_wafv2_web_acl" "cloudfront" {
  name  = "${var.environment}-cloudfront-web-acl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-cloudfront-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  web_acl_id          = aws_wafv2_web_acl.cloudfront.arn
  comment             = "Some comment"
  default_root_object = "index.html"

  #aliases = ["mysite.${local.my_domain}", "yoursite.${local.my_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    cache_policy_id  = data.aws_cloudfront_cache_policy.caching_optimized.id

    viewer_protocol_policy = "allow-all"
  }

  # Cache behavior with precedence 0
#   ordered_cache_behavior {
#     path_pattern     = "/content/immutable/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = local.s3_origin_id
#     cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
#     origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3_origin.id

#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }



  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "LK"]
    }
  }

  tags = {
    Environment = var.environment
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}




