# aws-console-signin

Enable users to connect to the AWS Console using an OIDC Access Token !

This repo provides the code and the Terraform configs to build and deploy an API Gateway backed by a Lambda, that enables Cognito users to connect to the AWS Console using their Access Token.


## Pre-requisites

The following resources must me deployed on your AWS account:
- A Cognito User Pool (Or any other Identity provider supported by Cognito Identity Pool) with a set of users.
- A Cognito Identity Pool: associates each user from the Cognito User Pool to an IAM Role. The selection of the IAM Role is based on specific rules (Role mapping).
- IAM Role(s): the IAM Role(s) of the Cognito Identy Pool Role mapping must exist.

## Build & Deploy the AWS-Console-Signin feature

Build lambda package:

> ./code/lambda-aws-signin/build.sh

Deploy the AWS Resources (API Gateway, Lambda, IAM Roles):

> cd deploy/terraform/
> terraform init
> terraform apply 



## How it works ?

![AWS Console Signin workflow](images/aws_console_signin.png?raw=true "Workflow")
