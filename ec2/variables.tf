# =========================================================
# VARIABLES — Dynamic EC2 Creation with Custom SGs
# =========================================================

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "instances" {
  description = "Map of EC2 instances with their configuration and custom SGs"
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
