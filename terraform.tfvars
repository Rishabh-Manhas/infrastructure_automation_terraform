region                = "us-east-1"
inst_image            = "ami-051f8a213df8bc089"
inst_type             = "t2.micro"
keyname               = "jenkins_key"
inbound_traffic_ports = [22, 8080]
keypath               = "./credentials/jenkins_key.pem"
