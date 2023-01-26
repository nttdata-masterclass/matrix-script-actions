resource "aws_iam_role" "main" {
  name = var.name
  path = "/"
  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "main" {
  name = "main"
  role = aws_iam_role.main.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:log-group:/aws/lambda/${var.name}*"
      ]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

resource "aws_lambda_function" "main" {
  function_name    = var.name
  description      = var.description
  filename         = var.filename
  handler          = var.handler
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  tags             = var.tags
  source_code_hash = var.source_code_hash
  role             = aws_iam_role.main.arn
}