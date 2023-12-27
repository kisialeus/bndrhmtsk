variable "application" {
  type = string
  description = "Application Environment."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Virtual Private Cloud (VPC) where resources will be provisioned."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "A list of private subnet IDs within the VPC."
}

variable "security_groups" {
  type        = any
  description = "The security group configuration for the external Application Load Balancer (ALB)."
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version."
}

variable "redis_node_type" {
  type        = string
  description = "Redis node type."
}

variable "cluster_size" {
  type        = number
  description = "Number of cache clusters in the replication group."
}

variable "multi_az_enabled" {
  type        = bool
  description = "Enable multi-AZ deployment."
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "Enable automatic failover."
}

variable "auth_token_enabled" {
  type        = bool
  description = "Enable authentication token."
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately."
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "Enable transit encryption."
}

variable "snapshot_retention_limit" {
  type        = number
  description = "Snapshot retention limit."
  default     = 7
}
