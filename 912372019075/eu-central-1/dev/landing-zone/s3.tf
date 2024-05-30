resource "aws_s3_bucket" "artifact_storage" {
  bucket = "uncalled-artifact-store-${local.short_region}-${local.env_short_names[var.env]}"
  acl    = "private"
}
