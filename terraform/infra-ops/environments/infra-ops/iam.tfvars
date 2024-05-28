parent_account_iam_users = {
  infra_admins = [
    "example-user@example.com",
  ]
}

oidc_providers = {
  github = {
    url = "https://token.actions.githubusercontent.com"
    client_id_list = [
      "sts.amazonaws.com"
    ]
    thumbprint_list = [
      "6938fd4d98bab03faadb97b34396831e3780aea1" # this is public https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
    ]
  },
  eks-dev = {
    url = "example-eks-dev-oidc-url"
    client_id_list = [
      "sts.amazonaws.com"
    ]
    thumbprint_list = [
      "example-eks-dev-oidc-url-thumbprint"
    ]
  },

}

iam_policies = {
  secret-get-policy = {
    description = "A policy to allow fetching all secrets from secret manager in the account"
    policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:ListSecrets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
  },
  ecr-push-policy = {
    description = "A policy to allow pushing to all repositories in the account"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
  }
}