module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  aws_region          = var.aws_region
  availability_zone   = var.availability_zone
  environment         = var.environment
  tags                = var.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  project_name       = var.project_name
  environment        = var.environment
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = [module.vpc.public_subnet_id]
  private_subnet_ids = [module.vpc.private_subnet_id]

  # Node Group User-Configurable Parameters
  instance_type           = var.instance_type
  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
  node_group_desired_size = var.node_group_desired_size
  disk_size               = var.node_group_disk_size

  tags = var.common_tags

  depends_on = [module.vpc]
}
