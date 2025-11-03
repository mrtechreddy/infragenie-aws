variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instances" {
  description = "Map of EC2 instances with configuration and security groups"
  type = map(object({
    ami            = string
    instance_type  = string
    key_name       = string
    security_groups = list(object({
      name          = string
      allowed_ports = list(number)
    }))
  }))
}
