# Terraform outputs will go here 

# Lambda function ARN: Useful for referencing the function in other AWS resources or for manual invocation/testing.
output "lambda_function_arn" {
  description = "ARN of the Lambda function that updates the Security Group."
  value       = aws_lambda_function.update_github_ips.arn
}

# EventBridge rule ARN: Useful for auditing, troubleshooting, or if you want to add more targets to the schedule.
output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule that triggers the Lambda function."
  value       = aws_cloudwatch_event_rule.daily.arn
}

# IAM role ARN: Useful for debugging permissions or if you need to attach additional policies later.
output "lambda_role_arn" {
  description = "ARN of the IAM role assumed by the Lambda function."
  value       = aws_iam_role.lambda_exec.arn
} 