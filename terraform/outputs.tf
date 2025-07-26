output "lambda_function_arn" {
  description = "ARN of the Lambda function that updates the Security Group."
  value       = aws_lambda_function.update_github_ips.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule that triggers the Lambda function."
  value       = aws_cloudwatch_event_rule.daily.arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role assumed by the Lambda function."
  value       = aws_iam_role.lambda_exec.arn
} 