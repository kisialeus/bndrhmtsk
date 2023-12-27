variable "application" {
  type        = string
  description = "The name of the application associated with this infrastructure."
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be provisioned."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Virtual Private Cloud (VPC) where resources will be provisioned."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "A list of subnet IDs within the VPC where resources will be provisioned."
}

variable "redis_allowed_subnets" {
  type        = list(string)
  description = "A list of subnet CIDR blocks allowed for communication with the cluster."
}

variable "redis_engine_version" {
  type        = string
  description = "The version of the Redis engine to use for the cluster."
}

variable "redis_node_type" {
  type        = string
  description = "The node type to be used for the Redis cluster."
}

variable "cluster_size" {
  type        = number
  description = "The number of cache nodes to create in the cluster."
}

variable "multi_az_enabled" {
  type        = bool
  description = "Enable Multi-AZ deployment for the cluster."
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "Enable automatic failover for the cluster."
}

variable "auth_token_enabled" {
  type        = bool
  description = "Enable authentication token for the cluster."
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately when updating the cluster."
  default = false
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "Enable transit encryption for data in transit for the cluster."
}

variable "snapshot_retention_limit" {
  type        = number
  description = "The number of days to retain automatic snapshots for the cluster."
  default     = 7
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
