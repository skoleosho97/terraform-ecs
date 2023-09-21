terraform {
    backend "s3" {
        bucket                  = "skole-ecs-demo"
        key                     = "state/terraform.tfstate"
        region                  = "us-east-1"
        shared_credentials_file = "~/.aws/credentials"
        profile                 = "default"
        encrypt                 = true
    }
    
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">= 5.6.2"
        }
    }

    required_version = ">= 1.1.0"
}

provider "aws" {
    region                      = var.region
    shared_credentials_files    = ["~/.aws/credentials"]
    profile                     = "default"
}

module "vpc" {
    source = "./modules/vpc"

    project = var.project
    env     = var.env
}

module "load_balancer" {
    source = "./modules/load_balancer"

    project             = var.project
    env                 = var.env
    backend_services    = var.backend_services
    vpc_id              = module.vpc.vpc_id
    public_subnets      = module.vpc.public_subnets
}

module "iam" {
    source = "./modules/iam"
}

module "ecs" {
    source = "./modules/ecs"

    exec_role_arn       = module.iam.ecs_task_execution_role_arn
    service_host        = module.load_balancer.service_host
    landing_dns         = module.load_balancer.landing_dns
    dashboard_dns       = module.load_balancer.dashboard_dns
    admin_dns           = module.load_balancer.admin_dns
    backend_lb_sg_id    = module.load_balancer.backend_lb_sg_id
    landing_lb_sg_id    = module.load_balancer.landing_lb_sg_id
    dashboard_lb_sg_id  = module.load_balancer.dashboard_lb_sg_id
    admin_lb_sg_id      = module.load_balancer.admin_lb_sg_id
    backend_tg          = module.load_balancer.backend_tg
    landing_tg_arn      = module.load_balancer.landing_tg_arn
    dashboard_tg_arn    = module.load_balancer.dashboard_tg_arn
    admin_tg_arn        = module.load_balancer.admin_tg_arn
    vpc_id              = module.vpc.vpc_id
    public_subnets      = module.vpc.public_subnets
    project             = var.project
    env                 = var.env
    backend_services    = var.backend_services
    all_services        = var.all_services
}