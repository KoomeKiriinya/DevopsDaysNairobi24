aws = {
  account_id             = "example-master-account-id"
  infra_region           = "example-region-id"
  identity_centre_region = "example-identity-center-region-id"
  
}

org_accounts = {
  dev = {
    email                      = "aws.dev@example.com"
    iam_user_access_to_billing = "DENY"
  }
  prod = {
    email                      = "aws.prod@example.com"
    iam_user_access_to_billing = "DENY"
  }
  infra-ops = {
    email                      = "aws.infra.ops@example.com"
    iam_user_access_to_billing = "DENY"
  }
}


identity_store_groups = {
  SuperAdmin = {
    description = "Infrastructure Administrators"
    users = {
      "ian.koome" = {
        display_name = "Ian Koome"
        email        = "ian@example.com"
      }

    }
  }
}