provider "aws" {
  region = "us-east-2"
}

# Security group
resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg-"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Dynamic EC2 instance creation
resource "aws_instance" "ec2_instance" {
  for_each = {
    "${var.instance_name}" = var.instance_type
  }

  ami                    = var.ami
  instance_type          = each.value
  key_name               = var.key_name != null ? var.key_name : null
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = each.key
  }
}
