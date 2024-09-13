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

#route tables

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.healthApp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.healthApp-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}


resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.healthApp.id

  tags = {
    Name = "private-rt"
  }
}

#subnet association 

resource "aws_route_table_association" "healthApp-public-association" {
  subnet_id      = aws_subnet.publicSn.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "healthApp-private-association" {
  subnet_id      = aws_subnet.privateSn.id
  route_table_id = aws_route_table.private-rt.id
}

#NACL for public subnet
resource "aws_network_acl" "healthApp-pub-nacl" {
  vpc_id = aws_vpc.healthApp.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "healthApp-pub-nacl"
  }
}

#NACL for private subnet
resource "aws_network_acl" "healthApp-priv-nacl" {
  vpc_id = aws_vpc.healthApp.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "healthApp-priv-nacl"
  }
}

#NACL Subnet Association 
resource "aws_network_acl_association" "pub-nacl-association" {
  network_acl_id = aws_network_acl.healthApp-pub-nacl.id
  subnet_id      = aws_subnet.publicSn.id
}

resource "aws_network_acl_association" "priv-nacl-association" {
  network_acl_id = aws_network_acl.healthApp-priv-nacl.id
  subnet_id      = aws_subnet.privateSn.id
}

# public security group 
resource "aws_security_group" "healthApp-web-sg" {
  name        = "healthApp-web-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.healthApp.id

  tags = {
    Name = "healthApp-web-sg"
  }
}


#public sg- ingress rule 
resource "aws_vpc_security_group_ingress_rule" "healthApp-web-sg-ingress-ssh" {
  security_group_id = aws_security_group.healthApp-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "healthApp-web-sg-ingress-http" {
  security_group_id = aws_security_group.healthApp-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}



#public sg - egress rule 
resource "aws_vpc_security_group_egress_rule" "healthApp-web-sg-egress-ssh" {
  security_group_id = aws_security_group.healthApp-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
