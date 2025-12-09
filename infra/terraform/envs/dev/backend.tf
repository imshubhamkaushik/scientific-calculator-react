terraform {
    backend "s3" {
        bucket = "scientific-calculator-react"
        key    = "scientific-calculator-react/dev/terraform.tfstate"
        region = "us-east-1"
        use_lockfile = true
        encrypt = true
    }
}