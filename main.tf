# Structure for a one time project with x instance(s)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

# Generate map for instance quantity
locals {
  quantity = 3
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create the project's VPC
resource "aws_vpc" "project" {
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
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Project"
  }
}

# Create resource to link subnet & route table
resource "aws_route_table_association" "project" {
  subnet_id      = aws_subnet.project.id
  route_table_id = aws_route_table.project.id
}

# Create group access for backend
resource "aws_security_group" "servers" {
  name        = "webservers"
  description = "Allow SSH public inbound traffic and private HTTP access"
  vpc_id      = aws_vpc.project.id

  ingress {
    description = "SSH for Ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["184.161.137.106/32"]
  }

  ingress {
    description = "http internal access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["34.231.239.156/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webservers"
  }
}

# Create group access for loadbalancers access
resource "aws_security_group" "loadbalancers" {
  name        = "allow_http_ssh"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.project.id

  ingress {
    description = "http external access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["184.161.137.106/32"]
  }

  ingress {
    description = "ssh for ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["184.161.137.106/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancers"
  }
}

# Create network interface
resource "aws_network_interface" "project" {
  count = local.quantity
  subnet_id       = aws_subnet.project.id
  private_ips     = ["10.202.0.10${count.index}"]
  security_groups = (count.index == 0 ? [aws_security_group.loadbalancers.id] : [aws_security_group.servers.id])  
}

# Create elastic IP
resource "aws_eip" "project" {
  instance = aws_instance.project[0].id
  vpc      = true
}

# Create EC2 instance
resource "aws_instance" "project" {
  count = local.quantity
  ami           = "ami-0aa7d40eeae50c9a9"
  instance_type = "t2.micro"
  key_name      = "Project"

  network_interface {
    network_interface_id = aws_network_interface.project[count.index].id
    device_index         = 0
  }

  tags = {
    Name = (count.index == 0 ? "Loadbalancer" : "Webserver${count.index}")
  }
}


