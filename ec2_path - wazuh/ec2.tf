# Create EC2 and attach to correct SG
resource "aws_instance" "Wazuh_EC2" {
  ami                         = "ami-0884d2865dbe9de4b"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.Private_Subnet.id
  security_groups             = [aws_security_group.Wazuh_SG.id]
  iam_instance_profile        = aws_iam_instance_profile.Wazuh_Instance_Profile.name
  associate_public_ip_address = false
  key_name                    = "Wazuh_Key"

  depends_on = [
    aws_vpc.Wazuh_VPC,
    aws_subnet.Private_Subnet,
    aws_security_group.Wazuh_SG
  ]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y debconf adduser procps awscli net-tools
              curl -sO https://packages.wazuh.com/4.10/wazuh-install.sh
              curl -sO https://packages.wazuh.com/4.10/config.yml
              EOF

  tags = {
    Name = "Wazuh_EC2"
  }
}

# Create Bastion Host in Public Subnet
resource "aws_instance" "Bastion_EC2" {
  ami                         = "ami-0884d2865dbe9de4b"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.Public_Subnet.id
  security_groups             = [aws_security_group.Bastion_SG.id]
  iam_instance_profile        = aws_iam_instance_profile.Wazuh_Instance_Profile.name # Might be poorly named, but I am copying over the same IAM permission here so we can utilize S3
  associate_public_ip_address = true
  key_name                    = "Wazuh_Key"

  depends_on = [
    aws_vpc.Wazuh_VPC,
    aws_subnet.Public_Subnet,
    aws_security_group.Wazuh_SG
  ]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y awscli net-tools
              aws s3 cp s3://wazuh-siem-mmt/Wazuh_Key.pem ~/
              EOF
  # With the last command, I'm copying over the key so it can be used to ssh into the local Wazuh Machine!

  tags = {
    Name = "Bastion_EC2"
  }
}

# Elastic IP for Bastion Host so that IP stays static
resource "aws_eip" "Bastion_EIP" {
  instance = aws_instance.Bastion_EC2.id
}

