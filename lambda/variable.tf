variable "lambda_role_arn" {
  description = "The ARN of the IAM role for the lambda function"
  type        = string
}

variable "execution_arn" {
  description = "The ARN of the API Gateway execution role"
  type        = string 
}