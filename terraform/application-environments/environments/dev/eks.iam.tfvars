eks_iam_roles = {
  external-secrets = {
    description    = "A role for external secrets"
    policy_names   = ["SecretGetPolicy"]
    namespace      = "external-secrets"
    serviceaccount = "external-secrets-dev"
  }
}
