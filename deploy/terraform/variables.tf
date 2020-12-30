variable "session_duration" {
  default = "3600"
}

variable "apigw_name" {
  default = "AwsSignin_ApiGw"
}

variable "lambda_name" {
  default = "AwsSignin_Lambda"
}

variable "tags" {
  type = map(string)
}