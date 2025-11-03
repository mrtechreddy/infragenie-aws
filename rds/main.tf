provider "aws" {
  region = var.region
}

resource "aws_db_instance" "infragenie_rds" {
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = true

  tags = {
    Name = "infragenie-rds"
  }
}

