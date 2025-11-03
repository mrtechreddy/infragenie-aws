variable "region" {
  default = "us-east-2"
}

variable "cluster_name" {
  default = "infragenie-eks"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for EKS nodes"
  type        = list(string)
}

