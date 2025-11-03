region = "us-east-1"

instances = {
  jenkins = {
    ami           = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.medium"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "jenkins-sg"
        allowed_ports = [22, 8080]
      }
    ]
  }

  tomcat = {
    ami           = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "tomcat-sg"
        allowed_ports = [22, 8080, 443]
      }
    ]
  }

  backend = {
    ami           = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t3.small"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "backend-sg"
        allowed_ports = [22, 3306]
      }
    ]
  }

  monitoring = {
    ami           = "ami-08962a4068733a2b6"
    instance_type = "t3.micro"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "monitoring-sg"
        allowed_ports = [22, 9090, 3000]
      }
    ]
  }
}
