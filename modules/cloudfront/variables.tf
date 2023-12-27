variable "application" {
  type = string
  description = "Application Environment."
}

variable "s3_bucket_name" {
  type = string
  description = "Bucket name for CloudFront origin"
}

variable "domain_name" {
  type = string
  description = "Domain name"
}

variable "aws_acm_certificate_arn" {
  type = string
  description = "ARN of ACM certificate"
}

variable "enable_private_access" {
  type = bool
  description = "Enable private access to s3"
  default = false
}

variable "enable_lambda_edge" {
  type = bool
  description = "Deploy lambda at edge to auth with cognito"
  default = false
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
