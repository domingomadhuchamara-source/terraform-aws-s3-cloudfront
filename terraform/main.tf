module "s3"{
source = "./modules/s3"
bucket_name = var.bucket_name
environment = var.environment
}

module "cloudfront" {
  source      = "./modules/cloudfront"
  bucket_id                   = module.s3.bucket_id
  bucket_arn                  = module.s3.bucket_arn
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  environment = var.environment
  sid         = var.sid
  effect      = var.effect
  type        = var.type
  identifiers = var.identifiers

  depends_on = [module.s3]
}
