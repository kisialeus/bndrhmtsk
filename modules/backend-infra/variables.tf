# Define a DynamoDB table configuration
variable "dynamodb" {
  type = object({
    name           = optional(string)
    read_capacity  = optional(number)
    write_capacity = optional(number)
  })

  default = {
    name           = "terraform_dynamodb"  # Default name for the DynamoDB table
    read_capacity  = 5                      # Default read capacity units
    write_capacity = 5                      # Default write capacity units
  }

  description = "Configuration for the DynamoDB table used by Terraform."
}

# Define an S3 bucket configuration
variable "s3_config" {
  type = object({
    s3_name           = optional(string)
    default_retention = optional(number)
  })

  default = {
    s3_name           = "terraform-stats-kisileuss"  # Default name for the S3 bucket
    default_retention = 5                            # Default retention period in days
  }

  description = "Configuration for the S3 bucket used by Terraform to store stats."
}
