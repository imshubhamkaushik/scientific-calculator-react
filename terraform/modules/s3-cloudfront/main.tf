provider "aws" {
    region = var.region  
}

resource "aws_s3_bucket" "sc_bucket" {
    bucket = var.bucket_name
    tags = { Name = "sc_bucket" }
}

resource "aws_s3_account_public_access_block" "block" {
    bucket = aws_s3_bucket.sc_bucket.id
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_iam_policy_document" "s3_policy" {
    statement {
        sid = "PublicReadGetObject"
        effect = "Allow"
        actions = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.sc_bucket.arn}/*"]
        principals {
            type = "AWS"
            identifiers = ["*"]
        }
    }
}

resource "aws_cloudfront_origin_access_identity" "sc_oai" {
    comment = "OAI for ${var.bucket_name}"  
}

resource "aws_cloudfront_distribution" "sc_cdn" {
    enabled = true
    origin {
        domain_name = aws_s3_bucket.sc_bucket.bucket_regional_domain_name
        origin_id = "s3-${var.bucket_name}"
        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.sc_oai.cloudfront_access_identity_path
        }
    }
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "s3-${var.bucket_name}"
        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 0
        max_ttl = 0
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
    tags = { Name = "sc_cdn" }
}

output "bucket_name" {
    description = "The name of the S3 bucket"
    value       = aws_s3_bucket.sc_bucket.id
}

output "cloudfront_domain_name" {
    description = "The CloudFront domain name"
    value       = aws_cloudfront_distribution.sc_cdn.domain_name
}