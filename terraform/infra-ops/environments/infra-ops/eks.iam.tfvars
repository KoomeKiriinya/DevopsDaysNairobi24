eks_iam_roles = {
  // naming convention is unique-name then -environment
  external-secrets-dev = {
    name           = "external-secrets"
    description    = "A role for external secrets"
    policy_names   = ["secret-get-policy"]
    namespace      = "external-secrets"
    serviceaccount = "external-secrets"
  }
}