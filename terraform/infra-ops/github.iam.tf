locals {
  github_oidc_allowed_repos = flatten([
    for org, allowedRepos in var.github_oidc_allowed_orgs : [
      for repo in allowedRepos : [
        "repo:${org}/${repo}:*"
      ]
    ]
  ])
  github_iam_roles_policy_attachments = flatten([
    for role, iam_role_details in var.github_iam_roles : [
      for policy_name in iam_role_details.policy_names : {
        iam_role    = role
        policy_name = policy_name
      }
    ]
  ])
}

data "aws_iam_policy_document" "github_oidc_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.oidc["github"].arn,
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_oidc_allowed_repos
    }
  }
}

resource "aws_iam_role" "github" {
  for_each = var.github_iam_roles

  name        = each.key
  description = each.value.description
  assume_role_policy = data.aws_iam_policy_document.github_oidc_policy.json
}

resource "aws_iam_role_policy_attachment" "github" {
  depends_on = [ aws_iam_role.github ]
  for_each = {
    for role_policy_attachment in local.github_iam_roles_policy_attachments :
    "${role_policy_attachment.iam_role}.${role_policy_attachment.policy_name}" => role_policy_attachment
  }
  policy_arn = aws_iam_policy.iam_policies[each.value.policy_name].arn
  role       = each.value.iam_role
}