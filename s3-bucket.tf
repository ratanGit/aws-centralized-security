# this is used by the FGTs to pull license and config files.
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper = false
  lower = true
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket   = "fgt-cloudinit-files${random_string.bucket_suffix.result}"

  tags = merge(local.common_tags, { Name = "Bucket-for-fortigate" })
}