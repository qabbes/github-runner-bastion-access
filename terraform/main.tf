# --- AWS Account Info for dynamic ARNs ---
data "aws_caller_identity" "current" {}

# --- Lambda Function ---
resource "aws_lambda_function" "update_github_ips" {
  function_name = "gha-bastion-access"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.12"

  filename         = "../lambda/lambda.zip"
  source_code_hash = filebase64sha256("../lambda/lambda.zip")

  environment {
    variables = {
      AWS_REGION      = var.aws_region
      SSH_PORT        = tostring(var.ssh_port)
      DESCRIPTION_TAG = "gha-bastion-access"
    }
  }

  tags = {
    Name = "gha-bastion-access"
  }
}

# --- IAM Role for Lambda ---
resource "aws_iam_role" "lambda_exec" {
  name               = "gha-bastion-access-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = {
    Name = "gha-bastion-access"
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

# --- IAM Policy for Lambda to update Bastion IP tables ---
resource "aws_iam_policy" "lambda_ssm_policy" {
  name = "lambda-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand"
        ],
        Resource = [
          "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ssm_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_ssm_policy.arn
}



# --- IAM Policy for Lambda basic execution ---
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- EventBridge Rule (Daily Trigger) ---
resource "aws_cloudwatch_event_rule" "daily" {
  name                = "gha-bastion-access-daily"
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

# --- Bastion Host Setup ---
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from anywhere (filtered by iptables)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}
# --- IAM Role for Bastion SSM access ---
resource "aws_iam_role" "bastion_ssm_role" {
  name = "bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_core" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# --- Bastion Instance ---
resource "aws_instance" "bastion" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = data.aws_subnet.default_subnet.id
  key_name        = aws_key_pair.bastion_key.key_name
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}