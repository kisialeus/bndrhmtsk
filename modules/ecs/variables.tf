variable "application" {
  type        = string
  description = "The name of the application associated with this infrastructure."
}

variable "app_services" {
  type        = list(string)
  description = "A list of services (ECS tasks) to be deployed within the infrastructure."
}

variable "account" {
  type        = number
  description = "The AWS account number where resources will be provisioned."
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be provisioned."
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The ARN of the ECS task execution role."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Virtual Private Cloud (VPC) where resources will be provisioned."
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of private subnet IDs within the VPC."
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnet IDs within the VPC."
}

variable "service_config" {
  type = map(object({
    name           = string
    is_public      = bool
    container_port = number
    host_port      = number
    cpu            = number
    memory         = number
    desired_count  = number
    alb_target_group = object({
      port              = number
      protocol          = string
      path_pattern      = list(string)
      health_check_path = string
      priority          = number
    })
    auto_scaling = object({
      max_capacity = number
      min_capacity = number
      cpu          = object({
        target_value = number
      })
      memory = object({
        target_value = number
      })
    })
  }))
}


variable "internal_alb_security_group" {
  type        = any
  description = "The security group configuration for the internal Application Load Balancer (ALB)."
}

variable "external_alb_security_group" {
  type        = any
  description = "The security group configuration for the external Application Load Balancer (ALB)."
}

variable "internal_alb_target_groups" {
  type        = map(object({
    arn = string
  }))
  description = "Map of internal ALB target group ARNs for each service."
}

variable "external_alb_target_groups" {
  type        = map(object({
    arn = string
  }))
  description = "Map of external ALB target group ARNs for each service."
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
