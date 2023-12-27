# VPC ID where resources will be deployed
variable "vpc_id" {
  type        = string
  description = "The ID of the Virtual Private Cloud (VPC) where resources will be deployed."
}

# Configuration for the Application Load Balancer (ALB)
variable "alb" {
  type        = any
  description = "Configuration for the Application Load Balancer (ALB) used in the infrastructure."
}

# Name for the internal URL
variable "internal_url_name" {
  type        = string
  description = "The name for the internal URL associated with the infrastructure."
}

# DNS hosted zone for the domain
variable "hosted_zone" {
  type        = string
  description = "The DNS hosted zone for the domain associated with the infrastructure."
}

# Name for the public URL
variable "public_url_name" {
  type        = string
  description = "The name for the public URL associated with the infrastructure."
}
