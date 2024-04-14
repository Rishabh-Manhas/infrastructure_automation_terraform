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
