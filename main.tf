provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

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
      Principal = "*"            # This means "Everyone"
      Action    = "s3:GetObject" # This means "Read the files"
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
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 Logging to use the key"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
         sse_algorithm     = "AES256"
    }
  }
}




resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encrypt" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.my_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "log_bucket" {
  bucket = "shopping-list-test-site-logs"
}

#Public Access Settings
resource "aws_s3_bucket_public_access_block" "log_bucket_public_block" {
  bucket = aws_s3_bucket.log_bucket.id

  # Changed these to 'true' since logs should stay private!
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Set the log bucket's ownership (Required for logging)
resource "aws_s3_bucket_ownership_controls" "log_bucket_oc" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#Connect your website bucket to the log bucket
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
  etag         = filemd5("index.html")
}


resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.website.id
  key          = "styles.css"          
  source       = "styles.css"        
  content_type = "text/css"  
  etag         = filemd5("styles.css")     
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.website.id
  key          = "app.js"         
  source       = "app.js"         
  content_type = "application/javascript" 
  etag         = filemd5("app.js")
}




output "url" {
  value = aws_s3_bucket_website_configuration.config.website_endpoint
}