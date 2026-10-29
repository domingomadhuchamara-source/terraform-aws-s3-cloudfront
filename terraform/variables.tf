variable "bucket_name" {
  default = "static-site-dev-2026"
}
variable "environment" {
  default = "dev"
}
variable "sid" {
  default = "AllowCloudFrontServicePrincipal"
}

variable "effect" {
  default = "Allow"
}

variable "type" {
  default = "Service"
}

variable "identifiers" {
  type    = list(string)
  default = ["cloudfront.amazonaws.com"]
}
