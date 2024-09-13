#VPC
resource "aws_vpc" "healthApp" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "healthApp"
  }
}

#Subnet

resource "aws_subnet" "publicSn" {
  vpc_id     = aws_vpc.healthApp.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch="true"

  tags = {
    Name = "publicSn"
  }
}

resource "aws_subnet" "privateSn" {
  vpc_id     = aws_vpc.healthApp.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "privateSn"
  }
}

#internet gw

resource "aws_internet_gateway" "healthApp-igw" {
  vpc_id = aws_vpc.healthApp.id

  tags = {
    Name = "healthApp-igw"
  }
}