# Structure for a one time project with 1 instance


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create the project's VPC
resource "aws_vpc" "project"{
  cidr_block = "10.202.0.0/16"
  tags = {
    Name = "Project"
  }
}

# Create gateway
resource "aws_internet_gateway" "project" {
  vpc_id = aws_vpc.project.id

  tags = {
    Name = "Project"
  }
}

# Create route table
resource "aws_route_table" "project" {
  vpc_id = aws_vpc.project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project.id
  }

  tags = {
    Name = "Project"
  }
}

# Create subnet
resource "aws_subnet" "project" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.202.0.0/24"

  tags = {
    Name = "Project"
  }
}

# Create resource to link subnet & route table
resource "aws_route_table_association" "project" {
  subnet_id      = aws_subnet.project.id
  route_table_id = aws_route_table.project.id
}

# Create group access for SSH
resource "aws_security_group" "project" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.project.id

  ingress {
    description      = "SSH for Ansible"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project allow_ssh"
  }
}

# Create network interface
resource "aws_network_interface" "project" {
  subnet_id       = aws_subnet.project.id
  private_ips     = ["10.202.0.10"]
  security_groups = [aws_security_group.project.id]
}

# Create elastic IP
resource "aws_eip" "project" {
  instance = aws_instance.project.id
  vpc      = true
}

# Create EC2 instance
resource "aws_instance" "project" {
  ami = "ami-0aa7d40eeae50c9a9"
  instance_type = "t2.micro"
  key_name = "Project"

  network_interface {
    network_interface_id = aws_network_interface.project.id
    device_index = 0
  }

  tags = {
    Name = "Project"
  }
}

# Output to Ansible hosts file
resource "local_file" "putblic_ip"{
  content = aws_instance.project.public_ip
  filename = "hosts"
}