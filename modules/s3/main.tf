resource "aws_s3_bucket" "s3_bucket" {
  for_each = {
    for bucket in var.s3_buckets : bucket.name => bucket
  }
  bucket = "${each.value.prefix}-${var.application}-${each.value.name}"
  tags = var.tags

}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  for_each = {
    for bucket in var.s3_buckets : bucket.name => bucket
  }
  bucket = aws_s3_bucket.s3_bucket[each.value.name].id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle" {
  for_each = {
    for bucket in var.s3_buckets : bucket.name => bucket if bucket.lifecycle_rules != null
  }
  bucket = aws_s3_bucket.s3_bucket[each.value.name].bucket
  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id = rule.value.rule_name
      status = "Enabled"
      expiration {
        days = rule.value.expiration_days
      }
      filter {
        prefix = rule.value.prefix
      }
    }
  }
}
