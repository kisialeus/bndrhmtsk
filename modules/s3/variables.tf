variable "s3_buckets" {
  type = map(object({
    name              = string
    prefix            = string
    lifecycle_rules   = optional(list(object({
      rule_name       = string
      expiration_days = number
      prefix          = string
    })))
  }))
}

variable "application" {
  type        = string
  description = "The name of the application associated with this infrastructure."
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
