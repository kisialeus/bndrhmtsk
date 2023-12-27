provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-stats-kisileuss"
    key            = "custom/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_dynamodb"
    encrypt        = true
  }
}

locals {
  internal_alb_target_groups = {for service, config in var.microservice_config : service => config.alb_target_group if !config.is_public}
  external_alb_target_groups   = {for service, config in var.microservice_config : service => config.alb_target_group if config.is_public}
}

module "iam" {
  source      = "./modules/iam"
  application = var.app_name
  s3_bucket_prefix = "htask"
}

module "vpc" {
  source             = "./modules/vpc"
  application        = var.app_name
  env                = var.env
  cidr               = var.cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  tags = var.tags
}

module "internal_alb_security_group" {
  source        = "./modules/security-group"
  name          = "${lower(var.app_name)}-internal-alb-sg"
  description   = "${lower(var.app_name)}-internal-alb-sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.internal_alb_config.ingress_rules
  egress_rules  = var.internal_alb_config.egress_rules
}

module "external_alb_security_group" {
  source        = "./modules/security-group"
  name          = "${lower(var.app_name)}-public-alb-sg"
  description   = "${lower(var.app_name)}-public-alb-sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.external_alb_config.ingress_rules
  egress_rules  = var.external_alb_config.egress_rules
}

module "internal_alb" {
  source            = "./modules/alb"
  name              = "${lower(var.app_name)}-internal-alb"
  subnets           = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id
  target_groups     = local.internal_alb_target_groups
  internal          = true
  listener_port     = 80
  listener_protocol = "HTTP"
  listeners         = var.internal_alb_config.listeners
  security_groups   = [module.internal_alb_security_group.security_group_id]
  tags = var.tags
}

module "external_alb" {
  source            = "./modules/alb"
  name              = "${lower(var.app_name)}-public-alb"
  subnets           = module.vpc.public_subnets
  vpc_id            = module.vpc.vpc_id
  target_groups     = local.external_alb_target_groups
  internal          = false
  listener_port     = 80
  listener_protocol = "HTTP"
  listeners         = var.external_alb_config.listeners
  security_groups   = [module.external_alb_security_group.security_group_id]
}

module "route53_private_zone" {
  source            = "./modules/route53"
  internal_url_name = var.internal_url_name
  alb               = module.internal_alb.internal_alb
  vpc_id            = module.vpc.vpc_id
  hosted_zone       = var.hosted_zone
  public_url_name   = var.app_name
}

module "ecr" {
  source           = "./modules/ecr"
  application      = var.app_name
  ecr_repositories = var.app_services
}

module "ecs" {
  source                      = "./modules/ecs"
  application                 = var.app_name
  app_services                = var.app_services
  account                     = var.account
  region                      = var.region
  service_config              = var.microservice_config
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  public_subnets              = module.vpc.public_subnets
  external_alb_security_group = module.external_alb_security_group
  internal_alb_security_group = module.internal_alb_security_group
  internal_alb_target_groups  = module.internal_alb.target_groups
  external_alb_target_groups  = module.external_alb.target_groups
  tags = var.tags
}



module "storages" {
  source       = "./modules/s3"
  application  = var.storage.name
  s3_buckets   = var.storage.s3_buckets
  tags = var.tags
}


############# CDN #############
module "cdn" {
  source = "./modules/cloudfront"
  application = var.app_name
  aws_acm_certificate_arn = var.certificate_arn
  domain_name = var.hosted_zone
  s3_bucket_name = "cfn-kisialeu"
}


data "aws_route53_zone" "route53_zone" {
  name         = var.hosted_zone
  private_zone = false
}


resource "aws_acm_certificate" "cf_acm_certificate" {
  for_each          = var.cloudfront_distributions
  domain_name       = "${each.key}.${var.hosted_zone}"
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

module "elasticashe" {
  source = "./modules/elasticcashe"
  application = var.app_name
  apply_immediately = false
  auth_token_enabled = false
  automatic_failover_enabled = false
  cluster_size = 0
  multi_az_enabled = false
  redis_engine_version = "6.x"
  redis_node_type = "cache.t4g.medium"
  security_groups = module.internal_alb_security_group
  transit_encryption_enabled = false
  vpc_id = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets
}

module "rds" {
  source = "./modules/rds"
  application = var.app_name
  backup_retention_period = 0
  deletion_protection = true
  engine_version = "13.8"
  instance_type = "db.t3.medium"
  publicly_accessible = false
  region = var.region
  security_groups = module.internal_alb_security_group
  vpc_id = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets
}

module "mq" {
  source = "./modules/mq"
  application = var.app_name
  deployment_mode = "SINGLE_INSTANCE"
  engine_type = "ACTIVEMQ"
  engine_version = "5.17.6"
  instance_type = "mq.t2.micro"
  publicly_accessible = false
  region = var.region
  security_groups = module.internal_alb_security_group
  vpc_id = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets
  username = var.app_name
}
#resource "aws_route53_record" "route53_record_cf_alias" {
#  for_each = var.cloudfront_distributions
#  zone_id  = data.aws_route53_zone.route53_zone.zone_id
#  name     = module.cdn[each.key].cloudfront_alternate_domain
#  type     = "A"
#
#  alias {
#    name                   = module.cdn[each.key].cloudfront_original_domain
#    zone_id                = module.cdn[each.key].cloudfront_zone_id
#    evaluate_target_health = true
#  }
#}

resource "aws_route53_record" "route53_record_cf_acm_validation" {
  for_each = {
    for distribution_key, distribution_val in var.cloudfront_distributions : distribution_key => {
      name   = tolist(aws_acm_certificate.cf_acm_certificate[distribution_key].domain_validation_options)[0].resource_record_name
      record = tolist(aws_acm_certificate.cf_acm_certificate[distribution_key].domain_validation_options)[0].resource_record_value
      type   = tolist(aws_acm_certificate.cf_acm_certificate[distribution_key].domain_validation_options)[0].resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "cf_acm_validation" {
  for_each                = var.cloudfront_distributions
  certificate_arn         = aws_acm_certificate.cf_acm_certificate[each.key].arn
  validation_record_fqdns = [aws_route53_record.route53_record_cf_acm_validation[each.key].fqdn]
}
