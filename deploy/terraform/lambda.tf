resource "aws_iam_role" "lambda" {
  name = "CloudwatchForLambda-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name = "CloudwatchForLambda-Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": [
          "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/var.lambda_name"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_lambda_function" "main" {
  function_name    = var.lambda_name
  filename         = "${path.root}/../../code/lambda-aws-signin/function.zip"
  source_code_hash = filebase64sha256("${path.root}/../../code/lambda-aws-signin/function.zip")
  role             = aws_iam_role.lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 5

  environment {
    variables = {
      ACCOUNT_ID       = data.aws_caller_identity.current.account_id
      IDENTITY_POOL_ID = aws_cognito_identity_pool.main.id
      USER_POOL_ID     = aws_cognito_user_pool.main.id
      SESSION_DURATION = var.session_duration
    }
  }

  tags = var.tags
}