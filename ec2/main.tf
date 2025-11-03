provider "aws" {
  region = var.region
}

resource "aws_security_group" "ec2_sg" {
  name        = "infragenie-ec2-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "infragenie_ec2" {
  ami                    = "ami-022661f8a4a1b91cf" # Amazon Linux 2 - us-east-2
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = var.instance_name
  }
}

