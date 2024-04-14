# infrastructure_automation_terraform
## Automating the infrastructure using Terraform first and install other required automation tools in it.

### Step 1: Installing Terraform on the host:
Refer [Installing Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
Demo for Amazon Linux EC2 Instance:

```sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform```

![Screenshot (280)](https://github.com/Rishabh-Manhas/infrastructure_automation_terraform/assets/77343955/eb101762-b55d-401f-b2e6-404747e3eb25)


### Step 2: Install Ansible on the host machine:
For this you need to install python and pip first-hand.
Refer [Installing Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

