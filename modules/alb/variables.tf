variable "name" {
  type        = string
  description = "The name of the Application Load Balancer (ALB)."
}

variable "internal" {
  type        = bool
  description = "Indicates whether the ALB is internal (true) or external (false)."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Virtual Private Cloud (VPC) where the ALB will be provisioned."
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs in which the ALB will be deployed."
}

variable "security_groups" {
  type        = list(string)
  description = "A list of security group IDs associated with the ALB."
}

variable "listeners" {
  type        = map(object({
    listener_port     = number
    listener_protocol = string
  }))
  description = "A map of listener configurations for the ALB."
}

variable "listener_port" {
  type        = number
  description = "The port on which the ALB listens for incoming traffic."
}

variable "listener_protocol" {
  type        = string
  description = "The protocol used by the ALB for routing traffic. (e.g., HTTP, HTTPS)"
}

variable "target_groups" {
  type        = map(object({
    port              = number
    protocol          = string
    path_pattern      = list(string)
    health_check_path = string
    priority          = number
  }))
  description = "A map of target group configurations for the ALB."
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
