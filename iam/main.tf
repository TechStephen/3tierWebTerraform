# Role for Ec2
resource "aws_iam_role" "ec2_role" {
  name = "CWEc2Role"

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

# Iam Policy For CW to read from Ec2
resource "aws_iam_policy" "cw_ec2_policy" {
  name = "CWEc2Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeTags",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "ssm:GetParameter"
        ]
        Effect = "Allow"
        Resource = "*"
    }]
  })
}

# Attach cw policy to role
resource "aws_iam_role_policy_attachment" "cw_ec2_attachment" {
    role = aws_iam_role.ec2_role.name
    policy_arn = aws_iam_policy.cw_ec2_policy.arn
}

# Attach dynamodb policy to role
resource "aws_iam_role_policy_attachment" "dynamodb_full_access_attachment" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Create instance profile to attach to ec2 for access
resource "aws_iam_instance_profile" "instance_profile" {
    name = "cw-ec2-instance-profile"
    role = aws_iam_role.ec2_role.name
}
