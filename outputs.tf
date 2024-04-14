
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
