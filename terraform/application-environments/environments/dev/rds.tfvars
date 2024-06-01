rds_postgres_instances = {
  example-db = {
    engine_version        = "15.5"
    family                = "postgres15"
    major_engine_version  = "15"
    instance_class        = "db.t4g.micro"
    storage_type          = "gp2"
    allocated_storage     = 20
    max_allocated_storage = 50
    storage_encrypted     = true

    db_name                = "example_db"
    db_user_name           = "example_db_user"
    create_random_password = false

    performance_insights_enabled = false

    create_db_subnet_group = false
    db_subnet_group_name   = "dev_database_subnet_grp"

    multi_az            = false
    availability_zone   = "eu-west-1a"
    publicly_accessible = false

    eks_access = "dev"
  }
}

rds_postgres_replica_instances = {}