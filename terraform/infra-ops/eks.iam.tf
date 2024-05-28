locals {
  eks_iam_roles_policy_attachments = flatten([
    for iam_role, iam_role_details in var.eks_iam_roles : [
      for policy_name in iam_role_details.policy_names : {
        iam_role    = iam_role_details.name
        policy_name = policy_name
      }
    ]
  ])
}

resource "aws_iam_role" "oidc_eks_iam_roles" {
  for_each    = var.eks_iam_roles
  name        = each.value.name
  description = each.value.description
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          // get env which is last substring after - separator on they key
          // assumption is that we have one cluster per environment , if adding another cluster we can pass this as a variable
          "Federated" : aws_iam_openid_connect_provider.oidc["eks-${element(split("-", each.key), length(split("-", each.key)) - 1)}"].arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.oidc_providers["eks-${element(split("-", each.key), length(split("-", each.key)) - 1)}"].url, "https://", "")}:sub" : "system:serviceaccount:${each.value.namespace}:${each.value.serviceaccount}"
          }
        }
      },
    ]
  })
  depends_on = [aws_iam_openid_connect_provider.oidc]
}

resource "aws_iam_role_policy_attachment" "roles_policy_attachment" {
  for_each = {
    for role_policy_attachment in local.eks_iam_roles_policy_attachments :
    "${role_policy_attachment.iam_role}.${role_policy_attachment.policy_name}" => role_policy_attachment
  }
  policy_arn = aws_iam_policy.iam_policies[each.value.policy_name].arn
  role       = each.value.iam_role
  depends_on = [ aws_iam_role.oidc_eks_iam_roles ]
}