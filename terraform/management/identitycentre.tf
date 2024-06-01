data "aws_ssoadmin_instances" "default" {
}

locals {
  identity_store_users = merge([
    for identity_store_group, identity_store_group_details in var.identity_store_groups : {
      for identity_store_user, identity_store_user_details in identity_store_group_details.users :
      identity_store_user => {
        email        = identity_store_user_details.email
        display_name = identity_store_user_details.display_name
        group        = identity_store_group
      }
    }
  ]...)

}

# sets up the iam identity centre users
resource "aws_identitystore_user" "users" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]

  for_each  = local.identity_store_users
  user_name = each.key

  display_name = each.value.display_name

  name {
    given_name  = split(" ", each.value.display_name)[0]
    family_name = split(" ", each.value.display_name)[1]
  }

  emails {
    value   = each.value.email
    primary = true
    type    = "work"
  }
}

# sets up the iam identity centre groups
resource "aws_identitystore_group" "groups" {
  for_each          = var.identity_store_groups
  display_name      = each.key
  description       = each.value.description
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

# sets up the iam identity centre user assignment to groups
resource "aws_identitystore_group_membership" "groups_membership" {
  for_each          = local.identity_store_users
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
  group_id          = aws_identitystore_group.groups[each.value.group].group_id
  member_id         = aws_identitystore_user.users[each.key].user_id
}

# sets up the iam identity centre permission sets
module "permission_sets" {
  depends_on = [
    aws_identitystore_group.groups,
  ]
  source = "github.com/cloudposse/terraform-aws-sso.git//modules/permission-sets?ref=1.2.0"

  permission_sets = [
    {
      name                                = "AdministratorAccess",
      description                         = "Allow Full Access to the account",
      relay_state                         = "",
      session_duration                    = "PT4H",
      tags                                = {},
      inline_policy                       = "",
      policy_attachments                  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      customer_managed_policy_attachments = []
    },
    {
      name                                = "ReadOnlyAccess",
      description                         = "Allow Read Only Access to the account",
      relay_state                         = "",
      session_duration                    = "PT1H",
      tags                                = {},
      inline_policy                       = "",
      policy_attachments                  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      customer_managed_policy_attachments = []
    }
  ]
}

# sets up the iam identity centre permission set assignment to AWS accounts
module "sso_account_assignments" {
  depends_on = [
    aws_identitystore_group.groups,
  ]
  source = "github.com/cloudposse/terraform-aws-sso.git//modules/account-assignments?ref=1.2.0"

  account_assignments = [
    {
      account             = var.aws.account_id,
      permission_set_arn  = module.permission_sets.permission_sets["AdministratorAccess"].arn,
      permission_set_name = "AdministratorAccess",
      principal_type      = "GROUP",
      principal_name      = aws_identitystore_group.groups["SuperAdmin"].display_name
    },
    {
      account             = aws_organizations_account.accounts["preprod"].id,
      permission_set_arn  = module.permission_sets.permission_sets["AdministratorAccess"].arn,
      permission_set_name = "AdministratorAccess",
      principal_type      = "GROUP",
      principal_name      = aws_identitystore_group.groups["SuperAdmin"].display_name
    },
    {
      account             = aws_organizations_account.accounts["prod"].id,
      permission_set_arn  = module.permission_sets.permission_sets["AdministratorAccess"].arn,
      permission_set_name = "AdministratorAccess",
      principal_type      = "GROUP",
      principal_name      = aws_identitystore_group.groups["SuperAdmin"].display_name
    },
    {
      account             = aws_organizations_account.accounts["infra-ops"].id,
      permission_set_arn  = module.permission_sets.permission_sets["AdministratorAccess"].arn,
      permission_set_name = "AdministratorAccess",
      principal_type      = "GROUP",
      principal_name      = aws_identitystore_group.groups["SuperAdmin"].display_name
    },
  ]
}
