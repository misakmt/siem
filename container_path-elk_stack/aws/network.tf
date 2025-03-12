# Create VPC
resource "aws_vpc" "elk_vpc" {
  cidr_block = "10.22.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "elk_public_subnet" {
  vpc_id                  = aws_vpc.elk_vpc.id
  cidr_block              = "10.22.0.0/25"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "elk_sg" {
  vpc_id = aws_vpc.elk_vpc.id

# Elasticsearch uses port 9200
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Kibana uses 5601 
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# For ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
