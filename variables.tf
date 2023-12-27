########################################################################################################################
# Application
variable "account" {
  type = number
  description = "AWS account number"
}

variable "hosted_zone" {
  type = string
  description = "Domain"
}
variable "region" {
  type = string
  description = "region"
}

variable "app_name" {
  type = string
  description = "Application name"
}

variable "app_services" {
  type = list(string)
  description = "service name list"
}

variable "env" {
  type = string
  description = "Environment"
}

variable "certificate_arn" {
  type = string
}
########################################################################################################################

# VPC
variable "cidr" {
  type = string
  description = "VPC CIDR"
}

variable "availability_zones" {
  type = list(string)
  description = "Availability zones that the services are running"
}

variable "private_subnets" {
  type = list(string)
  description = "Private subnets"
}

variable "public_subnets" {
  type = list(string)
  description = "Public subnets"
}
########################################################################################################################
#ALB
variable "internal_alb_config" {
  type = object({
    name      = string
    listeners = map(object({
      listener_port     = number
      listener_protocol = string
    }))
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  })
  description = "Internal ALB configuration"
}

variable "internal_url_name" {
  type = string
  description = "Friendly url name for the internal load balancer DNS"
}

variable "external_alb_config" {
  type = object({
    name      = string
    listeners = map(object({
      listener_port     = number
      listener_protocol = string
    }))
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  })
  description = "Public ALB configuration"
}
########################################################################################################################
# ECS
variable "microservice_config" {
  type = map(object({
    name           = string
    is_public      = bool
    container_port = number
    host_port = number
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
  description = "Microservice configuration"
}
########################################################################################################################
# Storages

variable "storage" {
  type = object({
    name      = string
    s3_buckets = map(object({
      name            = string
      prefix          = string
      lifecycle_rules = optional(list(object({
        rule_name       = string
        expiration_days = number
        prefix          = string
      })))
    }))
  })
}
########################################################################################################################
# CDN
variable "cloudfront_distributions" {
  type = map(object({
    enable_lambda_edge = optional(bool, false)
    enable_private_access = optional(bool, false)
    s3_user_prefix = optional(string, "ho")

  }))
  description = "List of CF names to create"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
