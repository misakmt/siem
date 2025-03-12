resource "aws_iam_role" "Wazuh_S3_Access" {
  name = "Wazuh_S3_Access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "S3_access_policy" {
  name        = "Wazuh_S3_Access_Policy"
  description = "Policy to allow EC2 instance access to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::wazuh-siem-mmt/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.Wazuh_S3_Access.name
  policy_arn = aws_iam_policy.S3_access_policy.arn
}

resource "aws_iam_instance_profile" "Wazuh_Instance_Profile" {
  name = "Wazuh_Instance_Profile"
  role = aws_iam_role.Wazuh_S3_Access.name
}
