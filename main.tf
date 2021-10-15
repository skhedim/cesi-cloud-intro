terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAXUXK4Z3TDCSIOVMG"
  secret_key = "BRpPXCpgabhstYfjt73FvR28rnNTUFPzEM19EySC"
  token      = "FwoGZXIvYXdzEOH//////////wEaDBORR/66hyW+KS6rciK9Ae6bK0AZZmIg5dmtEKywNucDy8y1j0d7GtKhGODUkh+L+eZbo18tJiGwMt3vVASZJYzaNi1bKny1XsN3wYIdCCv83V4D9nTI9F7zOX3rBrf/54qMUTv1REo3UuZKtzcuYuwFwTapOxEtF0db3KzzdwqmU/XYLn4QFEwvzUwcGibHrCptcxq24t32UsGx2Dm0MQgvA4Cr1Dn5Sdd8btxZk8omyCmQpkYUdaK6L4rgmm4d31YCBKgEEiFAV/HKTyjO1aSLBjItjXfb5dzAydmmOmWN7SvM9RU+2r74I31qdI1OWhdQnsM8ToIzgBar1RBC2bQr"
}

resource "aws_vpc" "epsi-tf" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "epsi-tf"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.epsi-tf.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-a-tf"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.epsi-tf.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-b-tf"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.epsi-tf.id
 
 
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-a-tf"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.epsi-tf.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-b-tf"
  }
}

resource "aws_internet_gateway" "igw-tf" {
  vpc_id = aws_vpc.epsi-tf.id

  tags = {
    Name = "igw-tf"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.epsi-tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-tf.id
  }

  tags = {
    Name = "public-tf"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key-tf"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "wordpress" {
  ami                         = "ami-02e136e904f3da870"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.public-a.id
  associate_public_ip_address = true

  tags = {
    Name = "wordpress"
  }

  user_data = file("${path.root}/script.sh")
}
