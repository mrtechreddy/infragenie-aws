provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# Create Security Group per instance
resource "aws_security_group" "instance_sg" {
  for_each = var.instances

  name_prefix = "${each.key}-sg-"
  description = "Security group for ${each.key}"

  dynamic "ingress" {
    for_each = each.value.allowed_ports
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

  tags = {
    Name = "${each.key}-sg"
  }
}

# Create EC2 instances
resource "aws_instance" "ec2" {
  for_each = var.instances

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  key_name               = each.value.key_name  # ✅ Uses your pem key name (must exist in AWS)
  vpc_security_group_ids = [aws_security_group.instance_sg[each.key].id]

  tags = {
    Name = each.key
  }
}

# Output instance details
output "instance_details" {
  value = {
    for name, inst in aws_instance.ec2 :
    name => {
      id   = inst.id
      type = inst.instance_type
      sg   = aws_security_group.instance_sg[name].name
      key  = inst.key_name
      ip   = inst.public_ip
    }
