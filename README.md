# infrastructure_automation_terraform

## Integrating Terraform and Ansible to automate and configure Infrastructure

### 1.	Introduction

The purpose of this project is to automate the setup of an EC2 instance using Terraform and configure it with Python, Java, and Jenkins using Ansible. The project aims to streamline the process of infrastructure creation and configuration, reducing manual effort and potential errors.


### 2.	Objectives

 The main objectives of this project are:
a.	Automate the creation of an EC2 instance using Terraform.
b.	Configure the EC2 instance with Python, Java, and Jenkins using Ansible.
c.	Ensure seamless integration between Terraform and Ansible.
d.	Validate the setup by accessing Jenkins on the EC2 instance.




### 3.	Methodology
The project is divided into several key milestones, each involving specific tasks to achieve the desired outcome. The milestones are as follows:
Part 1: Installing Terraform and Ansible

 #### a.	Install Terraform and Ansible on the host machine to set up the development environment.

```
sudo yum install -y yum-utils

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

sudo yum -y install terraform
```

  


#### b.	Install Python and pip, followed by Ansible using pip.
```
sudo yum install -y python python-pip
pip install ansible
```

#### c.	Install AWS CLI and configure it with AWS account credentials for accessing AWS services.

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install
```



### Part 2: Configuring AWS CLI in Host


#### a.	Create an AWS user in the AWS Management Console.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/876913a7-dbee-41e6-a441-eadb82189b51)

#### b.	Attach the "AmazonEC2FullAccess" policy to the user, granting necessary permissions.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/34b230fb-d663-414d-a3ca-0805ee8e224d)

#### c.	Generate access keys for the user and configure AWS CLI on the host machine.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/0a7a5978-e780-402d-971a-7d47658b2710)

 

### Part 3: Creating Key Pair in AWS Console.

#### a.	Create a key pair named "jenkins_key" in .pem format in the AWS console.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/361dc3b0-3390-4581-88ee-8bd925f3db19)
 
#### b.	Download the key pair and copy it to the Terraform host.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/d9fb53db-002b-4c88-b1a2-5690968524a6)

 
#### c.	Set appropriate permissions (400) to the key pair file for security.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/b648737f-8457-4f38-97a5-3feb1af118ce)

 
### Part 4: Setting Up Terraform Project.

#### a.	Create a project directory for the Terraform project
```
mkdir terraform_automation_project 
cd terraform_automation_project
```

#### b.	Write Terraform scripts including provider.tf, variable.tf, terraform.tfvars, main.tf, and output.tf.

#### c.	Use local-exec provisioner in main.tf to wait for EC2 instance creation.

We’re executing this provisioner execute sleep command to wait for ec2 instance to be created and ssh service to be started before creating inventory file and executing playbook, otherwise it won’t be able to connect with instance and the execution will fail.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/f2c81448-6c08-4d17-9790-5b1e8abea06e)
 

#### d.	Utilise ansible_host and ansible_playbook resource providers in Terraform for inventory creation and playbook execution.
 ![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/f324f4c0-29aa-4e91-9276-5521b25911ce)


### Part 5: Ansible Playbook Configuration.

#### a.	Create ansible_dir for writing the playbook install.yml.
```
mkdir ansible_dir
cd ansible_dir
vi install.yml 
```
#### b.	Write an ansible plabook to I=install Python, Java, and Jenkins on the EC2 instance using ansible.
install.yml
```
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
```

#### c.	Retrieve the initialadminpassword of Jenkins using debug and register module.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/3023b015-4cb2-4027-acad-b4e8ac288fa1)

#### d.	Configure a host file for Ansible and add a Terraform plugin line to redirect to the inventory created by Terraform.
hosts file:
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/1bfefb8c-27a6-461e-82e2-6a445ed61fb1)

#### e.	Create a config file for Ansible to ensure proper execution.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/715ea8d9-f849-416b-98ff-ebf0e1b3027e)

 
### Part 6: Copying Key Pair for SSH.
#### a.	Copy the jenkins_key.pem file to the directory mentioned in ansible.cfg file for SSH connection to the Terraform-created EC2 instance.
 ![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/3ad1dbde-fba5-4a7c-83e2-f7b657119306)

### Part 7: Running Terraform Script.

#### a.	Run terraform init to initialise all resource providers and validate the script.
 ![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/c37beab3-04cc-4957-8153-1ec2e387ad4c)

#### b.	Run terraform plan and terraform apply to execute the Terraform script.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/910d5973-9be2-42aa-a769-cd2947da2070)
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/339e69c9-d2ce-49a9-a5f7-8ab53785a85c)

Now running terraform apply:
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/4c062ccd-f5f6-49b9-adbf-7185b66f3770)
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/269633bc-0057-4a3c-a40f-1795b29982e1)

  
### Part 8: Verifying Installation of Python, Java and Jenkins.

#### a.	After script execution, the EC2 instance will be running and configured with Python, Java, and Jenkins.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/7ed7736d-30b1-42e2-82c9-d5bb82dd8279)
 
#### b.	Access the public URL of the instance provided in the output section of the script to access Jenkins.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/d90883dc-588d-46a1-af90-41ff38832c91)

 #### c.	Use the initial admin password to log in to Jenkins and complete the setup.
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/6da30a06-d367-42de-a272-c2fcba3acfa1)
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/a4f87a4d-c8ea-4294-93bd-5bff9a7b3fcb)
![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/aab82bb7-3ded-450d-8217-fc3b0bfef2cf)



### d.	Crosscheck the installation of Python, Java, and Jenkins on the EC2 instance by logging in to the instance using the AWS console.

![image](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/d34370ee-9548-4758-815a-aff5734f7c82)
 
## 4. Project Outcome

The project successfully automates the creation of an EC2 instance and configures it with Python, Java, and Jenkins using Terraform and Ansible. The outcome of the project is a fully functional EC2 instance with Jenkins accessible via a public URL. The automation reduces manual effort and ensures consistent and error-free infrastructure setup.

## 5. Conclusion

Integrating Terraform and Ansible provides a powerful automation solution for infrastructure provisioning and configuration. This project demonstrates the seamless integration of these tools to automate the setup of an EC2 instance and configure it with essential software. The automated process improves efficiency, eliminates manual errors, and standardised infrastructure deployments. The project can be further extended to incorporate additional tools and configurations as per specific requirements.
 


