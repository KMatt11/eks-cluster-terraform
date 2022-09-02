###### root/main.tf
module "vpc" {
  source           = "../../../../modules/vpc"
  vpc_cidr         = local.vpc_cidr
  tags             = local.tags
  public_sn_count  = 2
  private_sn_count = 2
  availabilityzone = "us-east-1a"
  azs              = 2
}

module "eks" {
  source          = "../../../../modules/eks"
  tags            = local.tags
  name            = local.name
  vpc_id          = module.networking.vpc_id
  ec2_ssh_key     = "ekscluster-kp"
  desired_size    = 2
  min_size        = 1
  max_size        = 5
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
}