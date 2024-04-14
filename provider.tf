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
