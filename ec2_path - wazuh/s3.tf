resource "aws_s3_bucket" "wazuh_s3" {
  bucket = "wazuh-siem-mmt"

  tags = {
    Name = "wazuh_s3"
  }
}

# Upload file to the S3 bucket
resource "aws_s3_object" "upload_file" {
  bucket = aws_s3_bucket.wazuh_s3.id
  key    = "Wazuh_Key.pem"
  source = "/Users/mt/.ssh/Wazuh_Key.pem"
  acl    = "private"
}