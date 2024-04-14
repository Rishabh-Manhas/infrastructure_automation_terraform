Integrating Terraform and Ansible to automate and configure Infrastructure

Description: 
Nowadays, infrastructure automation is critical. We tend to put the most emphasis on software development processes, but infrastructure deployment strategy is just as important. Infrastructure automation not only aids disaster recovery, but it also facilitates testing and development. 
Your organisation is adopting the DevOps methodology and in order to automate provisioning of infrastructure there's a need to set up a centralised server for Jenkins. 
Terraform is a tool that allows you to provision various infrastructure components. Ansible is a platform for managing configurations and deploying applications. It means you'll use Terraform to build a virtual machine, for example, and then use Ansible to install the necessary applications on that machine. 
Considering the Organisational requirement you are asked to automate the infrastructure using Terraform first and install other required automation tools in it. 
Tools required: Terraform, AWS account with security credentials, Keypair.
Expected Deliverables: 
●	Launch an EC2 instance using Terraform. 
●	Connect to the instance. 
●	Install Jenkins, Java and Python in the instance.
INDEX

1. Introduction


2. Objectives

Part 1: Installing Terraform and Ansible

Part 2: Configuring AWS CLI in Host

Part 3: Creating Key Pair in AWS Console

Part 4: Setting Up Terraform Project

Part 5: Ansible Playbook Configuration

Part 6: Copying Key Pair for SSH

Part 7: Running Terraform Script

Part 8: Verifying Installation of Python, Java and Jenkins


4. Project Outcome


5. Conclusion

1.	Introduction

The purpose of this project is to automate the setup of an EC2 instance using Terraform and configure it with Python, Java, and Jenkins using Ansible. The project aims to streamline the process of infrastructure creation and configuration, reducing manual effort and potential errors.


2.	Objectives

 The main objectives of this project are:
a.	Automate the creation of an EC2 instance using Terraform.
b.	Configure the EC2 instance with Python, Java, and Jenkins using Ansible.
c.	Ensure seamless integration between Terraform and Ansible.
d.	Validate the setup by accessing Jenkins on the EC2 instance.




3.	Methodology
The project is divided into several key milestones, each involving specific tasks to achieve the desired outcome. The milestones are as follows:
Part 1: Installing Terraform and Ansible

a.	Install Terraform and Ansible on the host machine to set up the development environment.

sudo yum install -y yum-utils

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

sudo yum -y install terraform

  


b.	Install Python and pip, followed by Ansible using pip.
sudo yum install -y python python-pip
pip install ansible

 

c.	Install AWS CLI and configure it with AWS account credentials for accessing AWS services.


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install
 



Part 2: Configuring AWS CLI in Host
a.	Create an AWS user in the AWS Management Console.
 

b.	Attach the "AmazonEC2FullAccess" policy to the user, granting necessary permissions.
 
c.	Generate access keys for the user and configure AWS CLI on the host machine.
 

Part 3: Creating Key Pair in AWS Console
a.	Create a key pair named "jenkins_key" in .pem format in the AWS console.
 
b.	Download the key pair and copy it to the Terraform host.
 
c.	Set appropriate permissions (400) to the key pair file for security.
 
Part 4: Setting Up Terraform Project
a.	Create a project directory for the Terraform project
mkdir terraform_automation_project 
cd terraform_automation_project


b.	Write Terraform scripts including provider.tf, variable.tf, terraform.tfvars, main.tf, and output.tf.
provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }
  }
}
provider "aws" {
  region = var.region
}
terraform.tfvars
region                = "us-east-1"
inst_image            = "ami-051f8a213df8bc089"
inst_type             = "t2.micro"
keyname               = "jenkins_key"
inbound_traffic_ports = [22, 8080]
keypath               = "./credentials/jenkins_key.pem"


variables.tf
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "inst_image" {
  type        = string
  default     = "ami-051f8a213df8bc089"
  description = "Amazon Machine Image ID for Amazon Linux 2023"
}

variable "inst_type" {
  type        = string
  default     = "t2.micro"
  description = "Size of VM"
}

variable "keyname" {
  type        = string
  default     = "mykey"
  description = "Name of Private keypair for EC2 instance"
}

variable "keypath" {
  type        = string
  default     = "./credentials/jenkins_key.pem"
  description = "Path of private key file to be used for EC2 instance"
}

variable "inbound_traffic_ports" {
  type        = list(number)
  default     = [22]
  description = "List of open ports for inbound traffic"

}





main.tf
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

output.tf
output "instance_id" {
  description = "ID of newly created EC2 instance."
  value       = aws_instance.jenkins_server.id
}
output "public_ip_add" {
  description = "Public IP address of EC2 instance."
  value       = aws_instance.jenkins_server.public_ip
}
output "ansible_playbook_stdout" {
  description = "Output of the Ansible Playbook Execution"
  value = ansible_playbook.install_python_jenkins.ansible_playbook_stdout
}




c.	Use local-exec provisioner in main.tf to wait for EC2 instance creation.
We’re executing this provisioner execute sleep command to wait for ec2 instance to be created and ssh service to be started before creating inventory file and executing playbook, otherwise it won’t be able to connect with instance and the execution will fail.
 

d.	Utilise ansible_host and ansible_playbook resource providers in Terraform for inventory creation and playbook execution.
 




Part 5: Ansible Playbook Configuration

a.	Create ansible_dir for writing the playbook install.yml.
mkdir ansible_dir
cd ansible_dir
vi install.yml 

b.	Install Python, Java, and Jenkins on the EC2 instance using the playbook.
install.yml
---
- name: Installing Python and Jenkins
  hosts: all
  remote_user: ec2-user
   
  tasks:
  - name: Update Package Repositories
    command: yum update -y
    become: true

  - name: Installing Python
    dnf:
      name: python3
      state: present
    become: true

  - name: Install Java
    dnf:
      name: java-17-amazon-corretto.x86_64
      state: present
    become: true
   
  - name: Add Jenkins Repository
    get_url: 
      url: https://pkg.jenkins.io/redhat/jenkins.repo
      dest: /etc/yum.repos.d/jenkins.repo
    become: true
  
  - name: Import Jenkins key 
    rpm_key:
      key: https://pkg.jenkins.io/redhat/jenkins.io-2023.key
      state: present
    become: true

  - name: Install Jenkins
    dnf:
      name: jenkins
      state: present
    become: true

  - name: Start Jenkins Service
    service:
      name: jenkins
      state: started
    become: true
  - name: Retrieve initial admin password
    shell: cat /var/lib/jenkins/secrets/initialAdminPassword
    register: initial_admin_password
    become: true
  - debug:
        msg: "Initial admin password: {{ initial_admin_password.stdout }}"    

c.	Retrieve the initialadminpassword of Jenkins using debug and register module.

 



d.	Configure a host file for Ansible and add a Terraform plugin line to redirect to the inventory created by Terraform.
hosts file
 

 

e.	Create a config file for Ansible to ensure proper execution.
 
Part 6: Copying Key Pair for SSH
a.	Copy the jenkins_key.pem file to the directory mentioned in ansible.cfg file for SSH connection to the Terraform-created EC2 instance.
 
Part 7: Running Terraform Script
a.	Run terraform init to initialise all resource providers and validate the script.
 
b.	Run terraform plan and terraform apply to execute the Terraform script.
  


Now running terraform apply
  




Part 8: Verifying Installation of Python, Java and Jenkins
a.	After script execution, the EC2 instance will be running and configured with Python, Java, and Jenkins.
 
b.	Access the public URL of the instance provided in the output section of the script to access Jenkins.
 

c.	Use the initial admin password to log in to Jenkins and complete the setup.
 
  




d.	Crosscheck the installation of Python, Java, and Jenkins on the EC2 instance by logging in to the instance using the AWS console.
 
  
4. Project Outcome

The project successfully automates the creation of an EC2 instance and configures it with Python, Java, and Jenkins using Terraform and Ansible. The outcome of the project is a fully functional EC2 instance with Jenkins accessible via a public URL. The automation reduces manual effort and ensures consistent and error-free infrastructure setup.
5. Conclusion

Integrating Terraform and Ansible provides a powerful automation solution for infrastructure provisioning and configuration. This project demonstrates the seamless integration of these tools to automate the setup of an EC2 instance and configure it with essential software. The automated process improves efficiency, eliminates manual errors, and standardised infrastructure deployments. The project can be further extended to incorporate additional tools and configurations as per specific requirements.
 


