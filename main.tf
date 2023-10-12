terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }

  backend "s3" {
    bucket         	   = "sctp1112"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-east-1"
    encrypt        	   = true
    dynamodb_table = "sctp21"
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC creation

resource "aws_vpc" "one-vpc" {
  cidr_block          = "10.3.0.0/16"
  instance_tenancy    = "default"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Name = "one-Vpc"
  }
}

resource "aws_vpc" "two-vpc" {
  cidr_block          = "10.4.0.0/16"
  instance_tenancy    = "default"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Name = "two-vpc"
  }
}

resource "aws_vpc" "three-vpc" {
  cidr_block          = "10.5.0.0/16"
  instance_tenancy    = "default"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-vpc"
  }
}

# Subnet creation
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.one-vpc.id
  cidr_block              = "10.3.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.two-vpc.id
  cidr_block              = "10.4.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet2"
  }
}

resource "aws_subnet" "public-subnet3" {
  vpc_id                  = aws_vpc.three-vpc.id
  cidr_block              = "10.5.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet3"
  }
}

# Internet Gateway creation
resource "aws_internet_gateway" "one-igw" {
  vpc_id = aws_vpc.one-vpc.id

  tags = {
    Name = "one-igw"
  }
}

resource "aws_internet_gateway" "two-igw" {
  vpc_id = aws_vpc.two-vpc.id

  tags = {
    Name = "two-igw"
  }
}

resource "aws_internet_gateway" "three-igw" {
  vpc_id = aws_vpc.three-vpc.id

  tags = {
    Name = "three-igw"
  }
}

# Route table for internet gateway
resource "aws_route_table" "one_igw_rt" {
  vpc_id = aws_vpc.one-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.one-igw.id
  }

  tags = {
    Name = "one_igw_rt"
  }
}

resource "aws_route_table" "two_igw_rt" {
  vpc_id = aws_vpc.two-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.two-igw.id
  }

  tags = {
    Name = "two_igw_rt"
  }
}

resource "aws_route_table" "three_igw_rt" {
  vpc_id = aws_vpc.three-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-igw.id
  }

  tags = {
    Name = "three_igw_rt"
  }
}

# Subnet association for internet-gateway
resource "aws_route_table_association" "subnet-association-igw-1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.one_igw_rt.id
}

resource "aws_route_table_association" "subnet-association-igw-2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.two_igw_rt.id
}

resource "aws_route_table_association" "subnet-association-igw-3" {
  subnet_id      = aws_subnet.public-subnet3.id
  route_table_id = aws_route_table.three_igw_rt.id
}

# Public security group
resource "aws_security_group" "public_sg1" {
  name        = "EKS-public-sg1"
  description = "Allow SSH and all traffic"
  vpc_id      = aws_vpc.one-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg1"
  }
}

resource "aws_security_group" "public_sg2" {
  name        = "EKS-public-sg2"
  description = "Allow SSH and all traffic"
  vpc_id      = aws_vpc.two-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg2"
  }
}

resource "aws_security_group" "public_sg3" {
  name        = "EKS-public-sg3"
  description = "Allow SSH and all traffic"
  vpc_id      = aws_vpc.three-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg3"
  }
}

# Key pair
resource "aws_key_pair" "EKS_kp" {
  key_name   = "EKS_kp"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "local_file" "EKS_kp" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "EKS_kp"
}

# Public EC2 instances
resource "aws_instance" "one-ec2" {
  ami           = "ami-0261755bbcb8c4a84"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.EKS_kp.key_name
  vpc_security_group_ids = [aws_security_group.public_sg1.id]
  subnet_id     = aws_subnet.public-subnet1.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 25
    volume_type = "io1"
    iops        = 100
  }

  tags = {
    Name = "one-ec2"
  }
}

resource "aws_instance" "two-ec2" {
  ami           = "ami-0261755bbcb8c4a84"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.EKS_kp.key_name
  vpc_security_group_ids = [aws_security_group.public_sg2.id]
  subnet_id     = aws_subnet.public-subnet2.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 25
    volume_type = "io1"
    iops        = 100
  }

  tags = {
    Name = "two-ec2"
  }
}

resource "aws_instance" "three-ec2" {
  ami           = "ami-0261755bbcb8c4a84"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.EKS_kp.key_name
  vpc_security_group_ids = [aws_security_group.public_sg3.id]
  subnet_id     = aws_subnet.public-subnet3.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 25
    volume_type = "io1"
    iops        = 100
  }

  tags = {
    Name = "three-ec2"
  }
}

# Null resource for public EC2
resource "null_resource" "core_public" {
  connection {
    type        = "ssh"
    host        = aws_instance.one-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }


  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      file("${path.module}/install.sh"),
      file("${path.module}/core.sh")
    ]
  }

  depends_on = [aws_instance.one-ec2]
}

# Null resource for public EC2
resource "null_resource" "ran_public" {
  connection {
    type        = "ssh"
    host        = aws_instance.two-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      file("${path.module}/install.sh"),
      file("${path.module}/ran.sh")
    ]
  }

  depends_on = [aws_instance.two-ec2]
}

# Null resource for public 
resource "null_resource" "mon_public" {
  connection {
    type        = "ssh"
    host        = aws_instance.three-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      file("${path.module}/install.sh"),
      file("${path.module}/monitoring.sh")
    ]
  }

  depends_on = [aws_instance.three-ec2]
}
