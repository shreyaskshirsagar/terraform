provider "aws" {
  region = "us-east-1"
}

# 1. VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "practice-terraform-vpc"
  }
}

# 2. Subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "practice-terraform-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "practice-terraform-igw"
  }
}

# 4. Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "practice-terraform-rt"
  }
}

# 5. Route Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# 6. Security Group
resource "aws_security_group" "main" {
  name        = "practice-terraform-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "practice-terraform-sg"
  }
}

# 7. EC2 Instance (Ubuntu)
resource "aws_instance" "ubuntu" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu Server 20.04 LTS in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  associate_public_ip_address = true
  key_name = "practice1_keypair" # <-- Replace this with your actual EC2 key pair name

  tags = {
    Name = "practice-terraform-ubuntu"
  }
}
