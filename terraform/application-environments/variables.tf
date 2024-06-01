variable "aws" {
  type = object({
    account_id        = string
    parent_account_id = string
    assume_role_name  = string
    region            = string
  })
}

variable "iam_role_users" {
  type = map(object({
    members     = list(string)
    policies    = optional(list(string))
    description = string
  }))
}

variable "environment" {
  type = string
}

variable "environment_prefix" {
  type = string
}

variable "vpc" {
  type = object({
    name                 = string
    cidr                 = string
    pub_subnets          = list(string)
    db_subnets           = list(string)
    priv_subnets         = list(string)
    intra_subnets        = list(string)
    create_elasticache_subnet_group = optional(bool, false)
    elasticache_subnets  = optional(list(string), [])
    enable_nat_gtw       = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    enable_dns_hostnames = optional(bool, true)
    single_nat_gtw       = optional(bool, true)
    one_nat_gtw_per_az   = optional(bool, false)
    requester_peering_connections = optional(map(object({
      peer_owner_id = string
      peer_vpc_id = string
    })), {})
  })
}

variable "eks_clusters" {
  type = map(object({
    cluster_version                        = string
    cloudwatch_log_group_retention_in_days = optional(number, 30)
    addon_versions = object({
      coredns = string
      kube-proxy = string
      vpc-cni = string
      aws-ebs-csi-driver = string
    })
    manage_aws_auth_configmap              = optional(bool, true)
    auth_roles = list(object({
      rolearn  = string
      username = string
      groups   = list(string)
    }))
    auth_users = list(string)
    eks_managed_node_group_defaults = object({
      disk_size = optional(number, 20)
    })
    eks_managed_node_groups = map(object({
      name            = string
      use_name_prefix = optional(bool, false)
      desired_size    = number
      max_size        = number
      min_size        = number
      instance_types  = list(string)
      capacity_type   = optional(string, "ON_DEMAND")
      key_name        = string
    }))

  }))
}

variable "iam_policies" {
  type = map(object({
    description = string
    policy      = string
  }))
}


variable "eks_iam_roles" {
  type = map(object({
    description    = string
    policy_names   = list(string)
    namespace      = string
    serviceaccount = string
  }))
}

variable "rds_postgres_instances" {
  type = map(object({
    engine_version               = string
    family                       = string
    major_engine_version         = string
    instance_class               = string
    storage_type                 = string
    allocated_storage            = number
    max_allocated_storage        = number
    storage_encrypted            = bool
    db_name                      = string
    db_user_name                 = string
    create_random_password       = bool
    performance_insights_enabled = bool
    create_db_subnet_group       = bool
    db_subnet_group_name         = string
    multi_az                     = bool
    availability_zone            = string
    publicly_accessible          = bool
    eks_access                   = string
    deletion_protection          = optional(bool, false)
    alternative_vpc_security_group_ids = optional(list(string), null)
  }))
}

variable "rds_postgres_replica_instances" {
  type = map(any)
}

variable "iam_users" {
  type = map(any)
}