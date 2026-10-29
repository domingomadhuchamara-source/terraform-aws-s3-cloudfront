bucket_name = "static-site-2026"
environment = "dev"

sid         = "AllowCloudFrontServicePrincipal"
effect      = "Allow"
type        = "Service"
identifiers = ["cloudfront.amazonaws.com"]
