provider "aws" {
    region = var.region  
}

data "aws_iam_policy_document" "s3_upload" {
    statement {
        sid = "AllowS3PutGet"
        actions = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
        resources = ["arn:aws:s3:::${var.s3_bucket}", "arn:aws:s3:::${var.s3_bucket}/*"]
    }  
}

resource "aws_iam_policy" "ci_s3_policy" {
    name = "ci-s3_upload_policy"
    policy = data.aws_iam_policy_document.s3_upload.json  
}

output "policy_urn" {
    value = aws_iam_policy.ci_s3_policy.arn  
}