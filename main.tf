
resource "aws_security_group" "jenkins_security" {
  name        = "jenkins-sg"
  description = "security group for jenkins server"

  dynamic "ingress" {
    for_each = var.inbound_traffic_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
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
    Name = "jenkins_server_security_group"
  }

}




resource "aws_instance" "jenkins_server" {
  ami             = var.inst_image
  instance_type   = var.inst_type
  key_name        = var.keyname
  security_groups = [aws_security_group.jenkins_security.name]

  depends_on = [
    aws_security_group.jenkins_security
  ]

  provisioner "local-exec" {
    command = "sleep 60"  # Wait for 60 seconds before executing the Ansible playbook
  }

  tags = {
    Name = "Jenkins_server"
  }

}

resource "ansible_host" "jenkins_inventory" {
  name   = aws_instance.jenkins_server.public_ip
  groups = ["jenkins"]

  variables = {
    ansible_user                 = "ec2-user"
    ansible_ssh_private_key_file = var.keypath
    ansible_python_interpreter   = "/usr/bin/python3"
  }
}

resource "ansible_playbook" "install_python_jenkins" {
  name     = aws_instance.jenkins_server.public_ip
  playbook = "./ansible_dir/install.yml"
}
