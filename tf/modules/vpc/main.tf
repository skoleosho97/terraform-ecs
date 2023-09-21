data "aws_availability_zones" "available" {}

locals {
    vpc_name    = "${var.project}-vpc"
    cidr        = "10.0.0.0/16"
    azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.0.0"

    name    = local.vpc_name
    cidr    = local.cidr
    azs     = local.azs

    public_subnets  = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 48)]
    private_subnets = [for k, v in local.azs : cidrsubnet(local.cidr, 4, k)]

    enable_dns_hostnames        = true
    enable_dns_support          = true
    manage_default_network_acl  = false 

    tags = {
        Name        = local.vpc_name
        Environment = var.env
    }
}