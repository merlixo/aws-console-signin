data "aws_iam_policy_document" "assume_role_k8s" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.k8s_node_role_arn]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cognito_group_mgt" {
  name               = "${local.resourceNameTag}-CognitoGroupMgt-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_k8s.json
}

data "aws_iam_policy_document" "cognito_group_mgt" {
  statement {
    sid = "GroupMgt"
    actions = [
      "cognito-idp:DeleteGroup",
      "cognito-idp:ListGroups",
      "cognito-idp:UpdateGroup",
      "cognito-idp:CreateGroup",
      "cognito-idp:GetGroup"
    ]
    resources = [
      aws_cognito_user_pool.main.arn
    ]
  }
  statement {
    sid = "SetRoleOnCognitoGroup"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/${local.resourceNameTag}*"
    ]
  }
}

resource "aws_iam_role_policy" "cognito_group_mgt" {
  name   = "${local.resourceNameTag}-CognitoGroupMgt-Policy"
  role   = aws_iam_role.cognito_group_mgt.id
  policy = data.aws_iam_policy_document.cognito_group_mgt.json
}
