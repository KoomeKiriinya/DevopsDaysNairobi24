module "eks" {
  for_each = var.eks_clusters
  source   = "terraform-aws-modules/eks/aws"
  version  = "19.21.0"

  cluster_name                    = each.key
  cluster_version                 = each.value.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = flatten([module.vpc.public_subnets, module.vpc.private_subnets])
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  create_iam_role      = true
  iam_role_name        = "${each.key}-cluster-role"
  iam_role_description = "${each.key} cluster role"
  iam_role_tags = {
    Purpose = "IAM access for ${each.key} cluster"
  }

  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = each.value.cloudwatch_log_group_retention_in_days

  cluster_addons = {
    coredns = {
      addon_version = "${each.value.addon_versions.coredns}"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version = "${each.value.addon_versions.kube-proxy}"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version = "${each.value.addon_versions.vpc-cni}"
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      addon_version = "${each.value.addon_versions.aws-ebs-csi-driver}"
      resolve_conflicts = "OVERWRITE"
    }
  }
  manage_aws_auth_configmap = each.value.manage_aws_auth_configmap
  aws_auth_roles            = each.value.auth_roles
  aws_auth_users            = each.value.auth_users

  create_cluster_security_group          = true
  cluster_security_group_name            = "${each.key}-cluster-sg"
  cluster_security_group_use_name_prefix = false
  cluster_security_group_description     = "${each.key} cluster security group"
  cluster_security_group_tags = {
    Name    = "${each.key}-cluster-sg"
    Purpose = "Security group rules for ${each.key} cluster"
  }

  cluster_encryption_config = {}

  eks_managed_node_group_defaults = {
    ami_type                        = "AL2_x86_64"
    subnet_ids                      = module.vpc.private_subnets
    ebs_optimized                   = true
    enable_monitoring               = true
    create_launch_template          = true
    launch_template_name            = "${each.key}-eks-managed-node"
    launch_template_use_name_prefix = true
    launch_template_description     = "${each.key} EKS managed node group launch template"
    launch_template_tags = {
      Purpose = "Custom launch template for ${each.key} eks managed nodes"
    }

    update_config = {
       max_unavailable = 1
     }

    # enable the containerd runtime
    bootstrap_extra_args = "--container-runtime containerd"

    create_iam_role          = true
    iam_role_name            = "${each.key}-managed-nodes-group-role"
    iam_role_use_name_prefix = true
    iam_role_description     = "${each.key} managed nodes group role"
    iam_role_tags = {
      Purpose = "IAM access for ${each.key} managed group nodes"
    }
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy: "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = each.value.eks_managed_node_group_defaults.disk_size
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      }
    }

    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    vpc_security_group_ids = []
  }
  eks_managed_node_groups             = each.value.eks_managed_node_groups
  create_node_security_group          = true
  node_security_group_name            = "${each.key}-nodes-sg"
  node_security_group_use_name_prefix = false
  node_security_group_enable_recommended_rules = false
  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
    }
    ingress_allow_tcp_8443_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      source_cluster_security_group = true
    }
    # allow metric server API traffic
    ingress_allow_tcp_4443_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 4443
      to_port                       = 4443
      source_cluster_security_group = true
    }
    # allow connections from EKS to the internet
    egress_all = {
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # allow connections from EKS to EKS (internal calls)
    ingress_self_all = {
      protocol  = "-1"
      from_port = 0
      to_port   = 0
      type      = "ingress"
      self      = true
    }
  }
  node_security_group_tags = {
    Name                     = "${each.key}-nodes-sg"
    Purpose                  = "Security group rules for ${each.key} cluster nodes"
    "karpenter.sh/discovery" = "true"
  }
  tags = {
    Name        = each.key
    Environment = var.environment
  }
}