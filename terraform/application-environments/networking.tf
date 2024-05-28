locals {
  allowed_public_ssh_cidr_ranges = [
  ]
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = var.vpc.name
  version = "4.0.2"

  cidr                         = var.vpc.cidr
  azs                          = slice(data.aws_availability_zones.available.names, 0, 3)
  database_subnets             = var.vpc.db_subnets
  create_database_subnet_group = true
  database_subnet_group_name   = "${var.vpc.name}_database_subnet_grp"
  private_subnets              = var.vpc.priv_subnets
  intra_subnets                = var.vpc.intra_subnets
  public_subnets               = var.vpc.pub_subnets
  elasticache_subnets          = var.vpc.elasticache_subnets
  create_elasticache_subnet_group = var.vpc.create_elasticache_subnet_group
  elasticache_subnet_group_name = "${var.vpc.name}-elasticache-subnet-grp"
  enable_nat_gateway           = var.vpc.enable_nat_gtw
  enable_dns_support           = var.vpc.enable_dns_support
  enable_dns_hostnames         = var.vpc.enable_dns_hostnames
  single_nat_gateway           = var.vpc.single_nat_gtw
  one_nat_gateway_per_az       = var.vpc.one_nat_gtw_per_az

  tags = {
    Environment = var.environment
  }
  vpc_tags = {
    Name = var.vpc.name
  }

  database_subnet_tags = {
    Name = "${var.vpc.name}_database_subnet"
  }
  database_subnet_group_tags = {
    Name = "${var.vpc.name}_database_subnet_grp"
  }
  public_subnet_tags = {
    Name = "${var.vpc.name}_public_subnet"
  }
  private_subnet_tags = {
    Name                     = "${var.vpc.name}_private_subnet"
    "karpenter.sh/discovery" = "true"
  }
  intra_subnet_tags = {}
  elasticache_subnet_tags = {
    Name = "${var.vpc.name}_elasticache_subnet"
  }
  elasticache_subnet_group_tags = {
    Name = "${var.vpc.name}-elasticache-subnet-grp"
  }
}

resource "aws_security_group" "all_egress" {
  name        = "${var.vpc.name}-allow-egress"
  description = "Allow outbound traffic from VPC to anywhere"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc.name}-allow-egress"
    Environment = var.environment
  }
}

resource "aws_security_group" "bastion_ssh_access" {
  name        = "${var.vpc.name}-allow-bastion-ssh-access"
  description = "Allow remote SSH access from sg to VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
  }

  tags = {
    Name        = "${var.vpc.name}-allow-bastion-ssh-access"
    Environment = var.environment
  }
}

resource "aws_vpc_peering_connection" "requester_peering_connections" {
  for_each = var.vpc.requester_peering_connections

  peer_owner_id = each.value.peer_owner_id
  peer_vpc_id   = each.value.peer_vpc_id
  vpc_id        = module.vpc.vpc_id

  tags = {
    Name = each.key
    Side = "Requester"
    Environment = var.environment
  }
}

resource "aws_security_group" "public_http_s" {
  name        = "${var.vpc.name}-allow-http-s"
  description = "Allow HTTP/HTTPS traffic from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc.name}-allow-http-s"
    Environment = var.environment
  }
}

resource "aws_security_group" "public_ssh_access" {
  name = "${var.vpc.name}-allow-public-ssh-access"
  description = "Allow remote SSH access from public addresses to VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.allowed_public_ssh_cidr_ranges
  }

  tags = {
    Name = "${var.vpc.name}-allow-public-ssh-access"
    Environment = var.environment
  }
}

resource "aws_security_group" "internal_postgres_tcp" {
  name        = "${var.vpc.name}-allow-internal-postgres-tcp"
  description = "Allow TCP inbound traffic from security group to VPC on port 5432"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL access from security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    self            = true
  }

  tags = {
    Name        = "${var.vpc.name}-allow-internal-postgres-tcp"
    Environment = var.environment
  }
}

resource "aws_security_group" "internal_mysql_tcp" {
  name        = "${var.vpc.name}-allow-internal-mysql-tcp"
  description = "Allow TCP inbound traffic from security group to VPC on port 3306"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Mysql access from security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    self            = true
  }

  tags = {
    Name        = "${var.vpc.name}-allow-internal-mysql-tcp"
    Environment = var.environment
  }
}