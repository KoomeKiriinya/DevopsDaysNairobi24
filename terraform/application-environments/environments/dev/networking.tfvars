vpc = {
  name = "dev"
  cidr = "10.30.0.0/16"
  pub_subnets = [
    "10.30.0.0/22",
    "10.30.4.0/22",
    "10.30.8.0/22",
  ]
  priv_subnets = [
    "10.30.32.0/19",
    "10.30.64.0/19",
    "10.30.96.0/19"
  ]
  db_subnets = [
    "10.30.21.0/24",
    "10.30.22.0/24",
    "10.30.23.0/24"
  ]
  intra_subnets        = []
  enable_nat_gtw       = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  single_nat_gtw       = true
  one_nat_gtw_per_az   = false
}