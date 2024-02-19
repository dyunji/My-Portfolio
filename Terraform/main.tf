resource "aws_s3_bucket" "myBucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "s3-bucket-owner" {
  bucket = aws_s3_bucket.myBucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.myBucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3-bucket-owner,
    aws_s3_bucket_public_access_block.public-access,
  ]

  bucket = aws_s3_bucket.myBucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "objects" {
  for_each     = fileset("./Files/", "**")
  bucket       = aws_s3_bucket.myBucket.id
  key          = each.key
  source       = "./Files/${each.value}"
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("./Files/${each.value}")
}

resource "aws_s3_bucket_website_configuration" "s3-bucket-config" {
  bucket = aws_s3_bucket.myBucket.id

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_bucket_acl.s3-acl]

}
