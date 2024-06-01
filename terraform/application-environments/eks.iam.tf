resource "aws_iam_role" "oidc_eks_iam_roles" {
  for_each    = var.eks_iam_roles
  name        = each.key
  description = each.value.description
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          // get env which is last substring after - separator on they key
          // assumption is that we have one cluster per environment , if adding another cluster we can pass this as a variable
          "Federated" : module.eks["${var.environment_prefix}"].oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks["${var.environment_prefix}"].oidc_provider}:sub" : "system:serviceaccount:${each.value.namespace}:${each.value.serviceaccount}"
          }
        }
      },
    ]
  })
}