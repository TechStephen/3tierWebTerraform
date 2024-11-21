# Create role so that private ec2 can talk to DynamoDB
resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "EC2DynamoDbRole"

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

# Attach policy to role
resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
    role = aws_iam_role.ec2_dynamodb_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Create instance profile to ATTACH TO EC2 for access
resource "aws_iam_instance_profile" "dynamodb_admind_profile" {
    name = "dynamodb-admin-profile"
    role = aws_iam_role.ec2_dynamodb_role.name
}