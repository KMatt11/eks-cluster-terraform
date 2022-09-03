###### root/main.tf
module "vpc" {
  source                  = "./modules/vpc"
  vpc_cidr                = "10.0.0.0/16"
  public_sn_count         = 2
  private_sn_count        = 2
  public_subnets          = module.vpc.public_subnets
  private_subnets         = module.vpc.private_subnets
}
 


module "eks" {
  source                  = "./modules/eks"
  vpc_id                  = module.vpc.vpc_id
  cluster_name            = "aws_eks_cluster.KP"
  endpoint_public_access  = true
  endpoint_private_access = false
  public_access_cidrs     = ["0.0.0.0/0"]
  node_group_name         = "luit22"
  desired_size            = 2
  min_size                = 1
  max_size                = 5
  scaling_desired_size    = 1
  scaling_max_size        = 1
  scaling_min_size        = 1
  instance_types          = ["t3.small"]
  tags                    = "KP_project22"
}
