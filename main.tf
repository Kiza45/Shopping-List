provider "aws" {
  region = "eu-west-1"
}


resource "aws_s3_bucket" "website" {
  bucket = "shopping-list-test-site"
}

#Public Access Settings
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.website.id
  index_document { suffix = "index.html" }
}

# 4. The Bucket Policy 
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