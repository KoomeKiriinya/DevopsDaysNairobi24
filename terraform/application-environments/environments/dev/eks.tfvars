eks_clusters = {
  dev = {
    cluster_version = "1.28"

    cloudwatch_log_group_retention_in_days = 30

    addon_versions = {
      coredns = "v1.9.3-eksbuild.9"
      kube-proxy = "v1.28.2-eksbuild.2"
      vpc-cni = "v1.15.1-eksbuild.1"
      aws-ebs-csi-driver = "v1.30.0-eksbuild.1"
    }

    # Enable to create & manage the aws-auth configmap
    manage_aws_auth_configmap = false
    auth_roles = []
    auth_users = []

    eks_managed_node_group_defaults = {
      disk_size = 30
    }
    eks_managed_node_groups = {
      server_group_1 = {
        name            = "server-group-1"
        use_name_prefix = false

        desired_size = 3
        max_size     = 3
        min_size     = 3

        instance_types = ["t3a.medium"]
        capacity_type  = "ON_DEMAND"

      }
    }
  }
}