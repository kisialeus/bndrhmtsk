
variable "region" {
  description = "AWS region where the MQ broker will be created."
}

variable "engine_type" {
  description = "The type of broker engine. Supported values: ACTIVEMQ, RABBITMQ"
}

variable "deployment_mode" {
  description = "The deployment mode of the broker. Supported values: SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ"
}

variable "engine_version" {
  description = "The version of the broker engine. For example, 5.15.0"
}

variable "vpc_subnets" {
  type        = list(string)
  description = "List of subnet IDs for the MQ subnet group."
}

variable "application" {
  type        = string
  description = "The name of the application associated with this infrastructure."
}

variable "publicly_accessible" {
  type        = bool
  description = "Flag to determine if the MQ  should be publicly accessible."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Virtual Private Cloud (VPC) where the MQ will be provisioned."
}

variable "security_groups" {
  type        = any
  description = "The security group configuration for the MQ."
}

variable "instance_type" {
  type  = string
  description = "MQ instance type"
}

variable "username" {
  type = string
  description = "Username for mq"
}
