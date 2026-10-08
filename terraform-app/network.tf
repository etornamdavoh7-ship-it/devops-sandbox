resource "aws_vpc" "devops_sandbox_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "devops_sandbox_igw" {
  vpc_id = aws_vpc.devops_sandbox_vpc.id
}

resource "aws_subnet" "sandbox_public_subnet_1a" {
  vpc_id                  = aws_vpc.devops_sandbox_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sandbox_public_subnet_1b" {
  vpc_id                  = aws_vpc.devops_sandbox_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sandbox_private_subnet_1a" {
  vpc_id            = aws_vpc.devops_sandbox_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "sandbox_private_subnet_1b" {
  vpc_id            = aws_vpc.devops_sandbox_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "sandbox_private_subnet_2a" {
  vpc_id            = aws_vpc.devops_sandbox_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"

}

resource "aws_subnet" "sandbox_private_subnet_2b" {
  vpc_id            = aws_vpc.devops_sandbox_vpc.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_eip" "devops_sandbox_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.devops_sandbox_igw]
}

resource "aws_nat_gateway" "devops_sandbox_nat_gw" {
  allocation_id = aws_eip.devops_sandbox_nat_eip.id
  subnet_id     = aws_subnet.sandbox_public_subnet_1a.id
}

resource "aws_route_table" "devops_sandbox_public_rt" {
  vpc_id = aws_vpc.devops_sandbox_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_sandbox_igw.id
  }
}

resource "aws_route_table_association" "devops_sandbox_public_rt_assoc" {
  for_each = {
    "1a" = aws_subnet.sandbox_public_subnet_1a.id
    "1b" = aws_subnet.sandbox_public_subnet_1b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.devops_sandbox_public_rt.id
}

resource "aws_route_table" "devops_sandbox_private_rt" {
  vpc_id = aws_vpc.devops_sandbox_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.devops_sandbox_nat_gw.id
  }
}

resource "aws_route_table_association" "devops_sandbox_private_rt_assoc" {
  for_each = {
    "1a" = aws_subnet.sandbox_private_subnet_1a.id
    "1b" = aws_subnet.sandbox_private_subnet_1b.id
    "2a" = aws_subnet.sandbox_private_subnet_2a.id
    "2b" = aws_subnet.sandbox_private_subnet_2b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.devops_sandbox_private_rt.id
}