provider "aws" {
  region = "eu-west-1"
}


resource "aws_s3_bucket" "website" {
  bucket = "shopping-list-test-site"
}

#Public Access Settings
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.website.id

  # tfsec:ignore:aws-s3-block-public-acls
  block_public_acls       = false
  # tfsec:ignore:aws-s3-block-public-policy
  block_public_policy     = false
  # tfsec:ignore:aws-s3-ignore-public-acls
  ignore_public_acls      = false
  # tfsec:ignore:aws-s3-no-public-buckets
  restrict_public_buckets = false
}


resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.website.id
  index_document { suffix = "index.html" }
}

resource "aws_s3_bucket_policy" "allow_public" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.website.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Create the Customer Managed Key (CMK)
resource "aws_kms_key" "my_key" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true # Another "High" security best practice
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.my_key.arn # Use the new key
      sse_algorithm     = "aws:kms"
    }
  }
}


#Create a separate bucket just for logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "shopping-list-logs-unique-id" # Change this!
}


Set the log bucket's ownership
resource "aws_s3_bucket_ownership_controls" "log_bucket_oc" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

Connect website bucket to the log bucket
resource "aws_s3_bucket_logging" "website_logging" {
  bucket = aws_s3_bucket.website.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "index.html" 
  content_type = "text/html"
}


resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.website.id
  key          = "styles.css"          
  source       = "styles.css"        
  content_type = "text/css"       
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.website.id
  key          = "app.js"         
  source       = "app.js"         
  content_type = "application/javascript" 
}




output "url" {
  value = aws_s3_bucket_website_configuration.config.website_endpoint
}