variable "aws" {
  type = object({
    account_id        = string
    parent_account_id = string
    assume_role_name  = string
    region            = string
  })
}


variable "oidc_providers" {
  type = map(object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
  }))

}

variable "parent_account_iam_users" {
  type = object({
    infra_admins = list(string)
  })
}
variable "environment" {
  type = string
}

variable "iam_policies" {
  type = map(object({
    description = string
    policy      = string
  }))
}

variable "eks_iam_roles" {
  type = map(object({
    name           = string
    description    = string
    policy_names   = list(string)
    namespace      = string
    serviceaccount = string
  }))
}

variable "ecr_repositories" {
  type = map(object({
    read_only_account_access   = list(string)
  }))
}

variable "github_oidc_allowed_orgs" {
  type = map(list(string))
}

variable "github_iam_roles" {
  type = map(object({
    description    = string
    policy_names   = list(string)
  }))
}

variable "public_ecr_repositories" {
  type = map(object({
    catalog_data = optional(map(any))
  }))
}
