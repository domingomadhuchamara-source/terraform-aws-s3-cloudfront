resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "s3" {
  bucket = "${var.bucket_name}-${var.environment}-${random_id.suffix.hex}"

  tags = {
    Name        = "${var.bucket_name}-${var.environment}"
    Environment = var.environment
  }
}
