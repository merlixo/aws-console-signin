
resource "aws_apigatewayv2_api" "main" {
  name          = var.apigw_name
  protocol_type = "HTTP"
  target        = aws_lambda_function.main.arn
  tags = var.tags
}

resource "aws_lambda_permission" "main" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
