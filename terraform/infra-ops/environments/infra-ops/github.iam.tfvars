github_oidc_allowed_orgs = {
  # github organization name : allowed repos
  KoomeKiriinya = [
    "DevopsDaysNairobi24",
  ]
}

github_iam_roles = {
  GithubECRPush = {
    description    = "A role an entity can assume to get ecr push access to the account"
    policy_names   = ["ecr-push-policy"]
  }
}