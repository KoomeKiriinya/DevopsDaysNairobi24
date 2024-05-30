locals {
  policy_names = toset(concat(flatten([
    for iam_role_user in var.iam_role_users : [
      iam_role_user.policies
    ]
  ]), keys(var.iam_policies)))
  role_polices = flatten([
    for iam_role_user, iam_role_user_details in var.iam_role_users : [
      for policy in iam_role_user_details.policies : {
        role_name   = iam_role_user
        policy_name = policy

      }
    ]
  ])
  eks_iam_roles_policy_attachments = flatten([
    for iam_role, iam_role_details in var.eks_iam_roles : [
      for policy_name in iam_role_details.policy_names : {
        role_name   = iam_role
        policy_name = policy_name
      }
    ]
  ])
}

data "aws_iam_policy_document" "policy_document" {
  for_each = var.iam_role_users
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    dynamic "principals" {
      for_each = toset(each.value.members)

      content {
        identifiers = ["arn:aws:iam::${var.aws["parent_account_id"]}:user/${principals.value}"]
        type        = "AWS"
      }
    }
  }
}

resource "aws_iam_role" "iam_role" {
  for_each           = var.iam_role_users
  name               = each.key
  description        = each.value.description
  assume_role_policy = data.aws_iam_policy_document.policy_document[each.key].json
}

resource "aws_iam_policy" "iam_policies" {
  for_each    = var.iam_policies
  name        = each.key
  description = each.value.description
  policy      = each.value.policy
}

data "aws_iam_policy" "iam_policies" {
  for_each   = local.policy_names
  name       = each.key
  depends_on = [aws_iam_policy.iam_policies]
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = {
    for policy_attachment in concat(local.eks_iam_roles_policy_attachments, local.role_polices) :
    "${policy_attachment.role_name}.${policy_attachment.policy_name}" => policy_attachment
  }
  policy_arn = data.aws_iam_policy.iam_policies[each.value.policy_name].arn
  role       = each.value.role_name
}