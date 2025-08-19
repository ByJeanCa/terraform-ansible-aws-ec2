terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}
provider "aws" {
  region = "us-east-2"
  profile = "jeanca"
}


resource "aws_security_group" "webserver" {
  name   = "webserver"
  vpc_id = "vpc-0249deba0939b37e1"

  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["201.206.0.0/16"]
  }

  ingress {
    description = "Allow http from anywhere"
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "test_instance" {
  ami           = "ami-0d1b5a8c13042c939"
  instance_type = "t3.micro"
  key_name      = "test"

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.webserver.id]
  subnet_id                   = "subnet-0ab6a9f3a2ae4fc1f"

}