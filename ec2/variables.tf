variable "instance_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami" {
  type    = string
  default = "ami-0c2b8ca1dad447f8a" # update for your region
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
