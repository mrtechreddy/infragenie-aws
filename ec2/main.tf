provider "aws" {
  region = var.region
}

# =========================================================
# Create security groups dynamically per instance
# =========================================================
resource "aws_security_group" "instance_sg" {
  for_each = {
    for instance_name, instance in var.instances :
    instance_name => flatten(instance.security_groups)
  }

  name_prefix = "${each.key}-sg-"
  description = "Custom SG for ${each.key}"

  dynamic "ingress" {
    for_each = [
      for sg in each.value :
      { from_port = sg.allowed_ports[0], to_port = sg.allowed_ports[0], protocol = "tcp" }
    ]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
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
      sgs  = [for sg in aws_security_group.instance_sg : sg.name if sg_key == name]
      ip   = instance.public_ip
    }
  }
}
