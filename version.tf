terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {}

# Configure the project's VPC
resource "aws_vpc" "Project"{
  cidr_block = "10.202.0.0/16"
  tags = { 
    Name = "Project"
  }
}




# Create EC2 instance
resource "aws_instance" "Homework1" {
  ami = "ami-0aa7d40eeae50c9a9"
  instance_type = "t2.micro"
  tags = {
    Name = "Homework1"
  }
}

# Output to Ansible hosts file
resource "local_file" "putblic_ip"{
  content = aws_instance.Homework1.public_ip
  filename = "hosts"
}