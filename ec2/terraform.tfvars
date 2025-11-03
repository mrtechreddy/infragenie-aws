instances = {
  jenkins = {
    ami           = "ami-08962a4068733a2b6"
    instance_type = "t2.medium"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "jenkins-sg"
        allowed_ports = [22, 8080]
      }
    ]
  },

  tomcat = {
    ami           = "ami-08962a4068733a2b6"
    instance_type = "t2.micro"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "tomcat-web"
        allowed_ports = [22, 8080, 443]
      }
    ]
  },

  backend = {
    ami           = "ami-08962a4068733a2b6"
    instance_type = "t3.small"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "backend-sg"
        allowed_ports = [22, 3306]
      }
    ]
  },

  monitoring = {
    ami           = "ami-08962a4068733a2b6"
    instance_type = "t3.medium"
    key_name      = "worklab"
    security_groups = [
      {
        name          = "grafana-sg"
        allowed_ports = [22, 3000]
      },
      {
        name          = "prometheus-sg"
        allowed_ports = [9090]
      }
    ]
  }
}
