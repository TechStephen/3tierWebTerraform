output "instance_profile_id" {
  value = aws_iam_instance_profile.instance_profile.id
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}