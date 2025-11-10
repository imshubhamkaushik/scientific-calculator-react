variable "bucket_name" {
    type = string
}

variable "region" {
    type = string
    default = "us-east-1"
}

variable "index_document" {
    type = string
    default = "index.html"
}

variable "error_document" {
    type = string
    default = "index.html"
}