# VPC CIDR Block
output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_intra_subnets" {
  value = module.vpc.intra_subnets
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}