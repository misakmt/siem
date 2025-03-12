# Create VPC
resource "aws_vpc" "Wazuh_VPC" {
  cidr_block           = "10.22.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Private Subnet
resource "aws_subnet" "Private_Subnet" {
  vpc_id                  = aws_vpc.Wazuh_VPC.id
  cidr_block              = "10.22.0.0/25"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "Public_Subnet" {
  vpc_id                  = aws_vpc.Wazuh_VPC.id
  cidr_block              = "10.22.0.128/25"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "Wazuh_IGW" {
  vpc_id = aws_vpc.Wazuh_VPC.id
}

resource "aws_route_table" "Public_Subnet_Route_Table" {
  vpc_id = aws_vpc.Wazuh_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Wazuh_IGW.id
  }
}

resource "aws_route_table_association" "Public_Subnet_Route_Association" {
  subnet_id      = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.Public_Subnet_Route_Table.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "NAT_EIP_Wazuh" {
  domain = "vpc"
}

# Create NAT Gateway in the Public Subnet
resource "aws_nat_gateway" "Wazuh_NAT" {
  allocation_id = aws_eip.NAT_EIP_Wazuh.id
  subnet_id     = aws_subnet.Public_Subnet.id
}

# Route Private Subnet traffic to NAT Gateway
resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.Wazuh_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Wazuh_NAT.id # Private subnet uses NAT Gateway
  }
}

resource "aws_route_table_association" "Private_Subnet_Route_Association" {
  subnet_id      = aws_subnet.Private_Subnet.id
  route_table_id = aws_route_table.Private_Route_Table.id
}

# Security Group for Wazuh EC2 Instance
resource "aws_security_group" "Wazuh_SG" {
  name        = "Wazuh_SG"
  description = "Security Group for Wazuh, allowing specific IP traffic"
  vpc_id      = aws_vpc.Wazuh_VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.22.0.0/25", "${aws_eip.Bastion_EIP.public_ip}32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.22.0.0/25"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.22.0.0/25"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Bastion EC2 Instance
resource "aws_security_group" "Bastion_SG" {
  name        = "Bastion_SG"
  description = "Security Group for Bastion (jump host), allowing specific IP traffic"
  vpc_id      = aws_vpc.Wazuh_VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["75.83.236.14/32"]
  }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["10.22.0.0/25"]
  # }

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["10.22.0.0/25"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}