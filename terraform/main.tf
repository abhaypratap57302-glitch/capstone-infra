terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_security_group" "k8s" {
  name        = "k8s-sg"
  description = "Firewall for the Minikube server"

  ingress {
    description = "SSH from inside the VPC (the controller)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress {
    description = "Our app (NodePort 30008)"
    from_port   = 30008
    to_port     = 30008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minikube" {
  ami                    = "ami-0dd60a46ecc6eac16"
  instance_type          = "c7i-flex.large"
  key_name               = "ap"
  vpc_security_group_ids = [aws_security_group.k8s.id]

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "minikube-node"
  }
}

output "private_ip" {
  value = aws_instance.minikube.private_ip
}
