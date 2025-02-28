# Initialise the VPC module
module "vpc" {
    source = "./modules/vpc"
}

module "iam" {
    source = "./modules/iam"
    node_group_1_role = module.eks.node_group_1_role
    # node_group_2_role = module.eks.node_group_2_role
    # node_group_3_role = module.eks.node_group_3_role
    oidc_provider = module.eks.oidc_provider
}

module "sqs" {
    source = "./modules/sqs"
}

module "eks" {
    source = "./modules/eks"
    vpc_id = module.vpc.vpc_id
    vpc_intra_subnets = module.vpc.vpc_intra_subnets
    vpc_private_subnets = module.vpc.vpc_private_subnets
    ebs_csi_role_arn = module.iam.ebs_csi_role_arn
}