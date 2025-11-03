variable "instance_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami" {
  type    = string
  default = "ami-0866a3c8686eaeeba" # update for your region
}

variable "key_name" {
  type        = string
  description = "Name of the existing AWS key pair to use"
  default     = null
}

variable "allowed_ports" {
  type    = list(number)
  default = [22]
}
