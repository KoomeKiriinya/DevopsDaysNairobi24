variable "aws" {
  type = object({
    account_id = string
    region     = string
  })
}

variable "org_accounts" {
  type = map(object({
    email                      = string
    iam_user_access_to_billing = optional(string, "DENY")
  }))
}

variable "iam_groups" {
  type = map(object({
    policies        = list(string)
    assume_policies = list(string)
    users           = list(string)
  }))
}

variable "iam_policies" {
  type = map(object({
    description = string
    policy      = string
  }))
}

variable "identity_store_groups" {
  type = map(object({
    description = string
    users = map(object({
      display_name = string
      email        = string
    }))
  }))
}
