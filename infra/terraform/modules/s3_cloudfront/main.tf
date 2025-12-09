locals {
  base_name = "${var.project_name}-${var.environment}"
}

# Main S3 bucket for static site
resource "aws_s3_bucket" "frontend-bucket" {
    bucket = "${local.base_name}-frontend-bucket"
    force_destroy = var.bucket_force_destroy
    
    tags = merge(
        var.tags,
        {
        Name        = "${local.base_name}-frontend-bucket"
        Project     = var.project_name
        Environment = var.environment
        }
    )  
}

# Ownership controls (required by newer AWS accounts)
resource "aws_s3_bucket_ownership_controls" "frontend-oc" {
  bucket = aws_s3_bucket.frontend-bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access (CloudFront will access the bucket via OAC)
resource "aws_s3_bucket_public_access_block" "frontend-pa" {
  bucket = aws_s3_bucket.frontend-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional logging bucket for CloudFront access logs
resource "aws_s3_bucket" "logs" {
    count = var.enable_logging ? 1 : 0
    bucket = "${local.base_name}-cf-logs"
    force_destroy = var.bucket_force_destroy

    tags = merge(
        var.tags,
        {
        Name        = "${local.base_name}-cf-logs"
        Project     = var.project_name
        Environment = var.environment
        }
    )  
}

resource "aws_s3_bucket_ownership_controls" "logs-oc" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "logs-pa" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Origin Access Control for CloudFront to access S3 bucket
resource "aws_cloudfront_origin_access_control" "frontend-oac" {
    name = "${local.base_name}-oac"
    description = "OAC for ${aws_s3_bucket.frontend-bucket} CloudFront to access S3 bucket"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
}
# Bucket policy to allow ClouFront to read objects
resource "aws_iam_policy_document" "s3_policy" {
    statement {
        actions = ["s3:GetObject"]
        principals {
            type        = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }
        resources = ["${aws_s3_bucket.frontend-bucket.arn}/*"]

        condition {
            test = "StringEquals"
            variable = "AWS:SourceArn"
            values = [aws_cloudfront_distribution.frontend-cf.arn]
        }
    }
}

resource "aws_s3_bucket_policy" "frontend-bucket-policy" {
    bucket = aws_s3_bucket.frontend-bucket.id
    policy = aws_iam_policy_document.s3_policy.json
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend-cf" {
    enabled = true
    is_ipv6_enabled = true
    price_class = var.cf_price_class
    default_root_object = "index.html"

    origin {
        domain_name = aws_s3_bucket.frontend-bucket.bucket_regional_domain_name
        origin_id   = "S3-frontend-origin"
        origin_access_control_id = aws_cloudfront_origin_access_control.frontend-oac.id
    }

    default_cache_behavior {
        target_origin_id = "S3-frontend-origin"
        viewer_protocol_policy = "redirect-to-https"
        
        allowed_methods = ["GET", "HEAD", "OPTIONS"]
        cached_methods  = ["GET", "HEAD"]

        compress = true

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
            }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    dynamic "logging_config" {
        for_each = var.enable_logging ? [1] : []
        content {
            bucket = aws_s3_bucket.logs[0].bucket_domain_name
            include_cookies = false
            prefix = "cloudfront/"
        }
    }

    # SPA-friendly error handling (react-router)
    custom_error_response {
        error_code         = 404
        response_code      = 200
        response_page_path = "/index.html"
        error_caching_min_ttl = 0
    }

    custom_error_response {
        error_code         = 403
        response_code      = 200
        response_page_path = "/index.html"
        error_caching_min_ttl = 0
    }

    tags = merge(
        var.tags,
        {
            Name        = "${local.base_name}-cf-default-cache-behavior"
            Project     = var.project_name
            Environment = var.environment
        }
    )
}