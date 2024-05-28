data "aws_ssm_parameter" "rds_postgres_db_user_pass" {
  for_each = var.rds_postgres_instances
  name     = "rds-postgres-${each.key}-db_user_pass"
}

module "postgres" {
  for_each = var.rds_postgres_instances
  source   = "terraform-aws-modules/rds/aws"
  version  = "5.9.0"

  identifier            = each.key
  engine                = "postgres"
  engine_version        = each.value.engine_version
  family                = each.value.family
  major_engine_version  = each.value.major_engine_version
  instance_class        = each.value.instance_class
  storage_type          = each.value.storage_type
  iops                  = lookup(each.value, "iops", null)
  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  storage_encrypted     = each.value.storage_encrypted

  db_name                = each.value.db_name
  username               = each.value.db_user_name
  create_random_password = each.value.create_random_password
  password               = data.aws_ssm_parameter.rds_postgres_db_user_pass[each.key].value
  port                   = 5432

  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", null)

  multi_az               = lookup(each.value, "multi_az", true)
  availability_zone      = lookup(each.value, "availability_zone", null)
  publicly_accessible    = each.value.publicly_accessible
  create_db_subnet_group = each.value.create_db_subnet_group
  db_subnet_group_name   = each.value.db_subnet_group_name
  vpc_security_group_ids = each.value.alternative_vpc_security_group_ids != null ? each.value.alternative_vpc_security_group_ids : [
    module.eks[each.value.eks_access].node_security_group_id,
    aws_security_group.internal_postgres_tcp.id
  ]

  maintenance_window                     = "Mon:04:00-Mon:05:00"
  enabled_cloudwatch_logs_exports        = ["postgresql", "upgrade"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 14

  backup_window           = "03:00-04:00"
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = lookup(each.value, "deletion_protection", false)

  create_monitoring_role      = true
  monitoring_interval         = 60
  monitoring_role_name        = "${each.key}-enhanced-monitoring"
  monitoring_role_description = "Monitoring role for enhanced metrics reporting"

  create_db_option_group = false

  parameters = [
    {
      name  = "client_encoding"
      value = "utf8"
    },
    {
      name  = "rds.force_ssl"
      value = "1"
    }
  ]
  tags = {
    Name        = each.key
    Environment = var.environment
  }

  db_instance_tags = {
    "Name" = "${each.key}_instance"
  }
  db_parameter_group_tags = {
    "Mame" = "${each.key}_param_grp"
  }
}

module "postgres_replica" {
  for_each = var.rds_postgres_replica_instances
  source   = "terraform-aws-modules/rds/aws"
  version  = "5.9.0"

  identifier            = each.key
  engine                = "postgres"
  engine_version        = each.value.engine_version
  family                = each.value.family
  major_engine_version  = each.value.major_engine_version
  instance_class        = each.value.instance_class
  storage_type          = each.value.storage_type
  iops                  = lookup(each.value, "iops", null)
  max_allocated_storage = each.value.max_allocated_storage
  storage_encrypted     = each.value.storage_encrypted

  replicate_source_db = each.value.master_instance_id

  port = 5432

  create_random_password = false

  performance_insights_enabled = false

  multi_az               = false
  availability_zone      = lookup(each.value, "availability_zone", null)
  publicly_accessible    = false
  create_db_subnet_group = false
  vpc_security_group_ids = each.value.alternative_vpc_security_group_ids != null ? each.value.alternative_vpc_security_group_ids : [
    module.eks[each.value.eks_access].node_security_group_id,
    aws_security_group.internal_postgres_tcp.id
  ]

  maintenance_window                     = "Mon:09:00-Mon:10:00"
  enabled_cloudwatch_logs_exports        = ["postgresql", "upgrade"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 14

  backup_window           = "08:00-09:00"
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = lookup(each.value, "deletion_protection", false)

  create_monitoring_role      = true
  monitoring_interval         = 60
  monitoring_role_name        = "${each.key}-enhanced-monitoring"
  monitoring_role_description = "Monitoring role for enhanced metrics reporting"

  create_db_option_group = false

  parameters = [
    {
      name  = "client_encoding"
      value = "utf8"
    },
    {
      name  = "rds.force_ssl"
      value = "1"
    }
  ]
  tags = {
    Name        = each.key
    Environment = var.environment
  }

  db_instance_tags = {
    "Name" = "${each.key}_instance"
  }
  db_parameter_group_tags = {
    "Mame" = "${each.key}_param_grp"
  }
}