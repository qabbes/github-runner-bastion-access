
# --- Lambda Function ---
resource "aws_lambda_function" "update_github_ips" {
  function_name = "github-ssh-sg-updater"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.12"

  filename         = "../lambda/lambda.zip"
  source_code_hash = filebase64sha256("../lambda/lambda.zip")

  environment {
    variables = {
      SECURITY_GROUP_ID = var.security_group_id
      AWS_REGION        = var.aws_region
      SSH_PORT          = tostring(var.ssh_port)
      DESCRIPTION_TAG   = "GitHubActions"
    }
  }
  
   tags = {
    Name        = "github-ssh-sg-updater-lambda-role"
  }
}

# --- IAM Role for Lambda ---
resource "aws_iam_role" "lambda_exec" {
  name = "github-ssh-sg-updater-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = {
    Name        = "github-ssh-sg-updater-lambda-role"
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --- IAM Policy for Lambda to update Security Group ---
resource "aws_iam_policy" "lambda_sg_update" {
  name        = "github-ssh-sg-updater-policy"
  description = "Allow Lambda to update Security Group ingress rules."
  policy      = data.aws_iam_policy_document.lambda_sg_update.json
}

data "aws_iam_policy_document" "lambda_sg_update" {
  statement {
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = ["arn:aws:ec2:${var.aws_region}:*:security-group/${var.security_group_id}"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_sg_update_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sg_update.arn
}

# --- IAM Policy for Lambda basic execution ---
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- EventBridge Rule (Daily Trigger) ---
resource "aws_cloudwatch_event_rule" "daily" {
  name                = "github-ssh-sg-updater-daily"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.daily.name
  target_id = "LambdaFunction"
  arn       = aws_lambda_function.update_github_ips.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_github_ips.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
} 