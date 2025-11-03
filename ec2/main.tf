#############################################
# Provider Configuration
#############################################
provider "aws" {
  region = var.region
}

#############################################
# Create Dynamic Security Groups
#############################################
resource "aws_security_group" "instance_sg" {
  for_each = {
    for instance_name, instance in var.instances :
    instance_name => instance.security_groups
  }

  name_prefix = "${each.key}-"
  description = "Security group for ${each.key}"

  # Create dynamic ingress rules based on allowed ports
  dynamic "ingress" {
    for_each = flatten([
      for sg in each.value : [
        for port in sg.allowed_ports : {
          from_port   = port
          to_port     = port
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    ])
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Allow all egress
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

#############################################
# Create EC2 Instances
#############################################
resource "aws_instance" "ec2_instance" {
  for_each = var.instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  # Attach corresponding security group(s)
  vpc_security_group_ids = [
    for sg_key, sg_val in aws_security_group.instance_sg :
    sg_val.id if sg_key == each.key
  ]

  tags = {
    Name = each.key
  }
}

#############################################
# Outputs
#############################################
output "ec2_instances" {
  value = {
    for name, instance in aws_instance.ec2_instance :
    name => {
      instance_id = instance.id
      type        = instance.instance_type
      key         = instance.key_name
      public_ip   = instance.public_ip
      security_groups = [
        for sg_key, sg_val in aws_security_group.instance_sg :
        sg_val.name if sg_key == name
      ]
    }
  }
}
