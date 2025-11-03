provider "aws" {
  region = "us-east-1" # ✅ Change to your preferred region
}

# =========================================================
# Create security groups dynamically per instance
# =========================================================
resource "aws_security_group" "instance_sg" {
  for_each = { for k, v in var.instances : k => v.security_groups }

  name_prefix = "${each.key}-sg-"
  description = "Custom SG for ${each.key}"

  dynamic "ingress" {
    for_each = flatten([
      for sg in each.value : [
        for port in sg.allowed_ports : {
          name       = sg.name
          from_port  = port
          to_port    = port
          protocol   = "tcp"
          cidr_block = "0.0.0.0/0"
        }
      ]
    ])
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr_block]
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

# =========================================================
# Create EC2 instances dynamically with corresponding SGs
# =========================================================
resource "aws_instance" "ec2_instance" {
  for_each = var.instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  # Attach all security groups created for this instance
  vpc_security_group_ids = [
    for sg_key, sg_val in aws_security_group.instance_sg :
    sg_val.id if sg_key == each.key
  ]

  tags = {
    Name = each.key
  }
}

# =========================================================
# Outputs
# =========================================================
output "instances" {
  value = {
    for name, instance in aws_instance.ec2_instance :
    name => {
      id   = instance.id
      type = instance.instance_type
      key  = instance.key_name
      sg   = [for sg in aws_security_group.instance_sg : sg.name if sg.key == name]
      ip   = instance.public_ip
    }
  }
}
