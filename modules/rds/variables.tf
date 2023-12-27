variable "instance_type" {
  type        = string
  description = "The instance type for the RDS cluster instances."
}

variable "publicly_accessible" {
  type        = bool
  description = "Flag to determine if the RDS cluster should be publicly accessible."
}

variable "engine_version" {
  type        = string
  description = "The version of the database engine to use for the RDS cluster."
}

variable "backup_retention_period" {
  type        = number
  description = "The number of days to retain automated backups for the RDS cluster."
}

variable "deletion_protection" {
  type        = bool
  description = "Flag to enable deletion protection for the RDS cluster."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "List of subnet IDs for the RDS cluster subnet group."
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be provisioned."
}

variable "application" {
  type        = string
  description = "The name of the application associated with this infrastructure."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Virtual Private Cloud (VPC) where the RDS cluster will be provisioned."
}

variable "security_groups" {
  type        = any
  description = "The security group configuration for the RDS cluster."
}
