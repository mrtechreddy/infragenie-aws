#############################################
# Provider Configuration
#############################################
provider "aws" {
  region = var.region
}

#############################################
# Networking — VPC and Subnet
#############################################

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "infragenie-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "infragenie-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "infragenie-igw"
  }
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "infragenie-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.rt.id
}

#############################################
# Dynamic Security Groups per instance
#############################################
resource "aws_security_group" "instance_sg" {
  for_each = {
    for instance_name, instance in var.instances :
    instance_name => instance.security_groups
  }

  name_prefix = "${each.key}-"
  description = "Security group for ${each.key}"
  vpc_id      = aws_vpc.main_vpc.id  # ✅ FIXED: Attach to our custom VPC

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
# EC2 Instances (Dynamic)
#############################################
resource "aws_instance" "ec2_instance" {
  for_each = var.instances

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  key_name               = each.value.key_name
  subnet_id              = aws_subnet.main_subnet.id
  associate_public_ip_address = true

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
