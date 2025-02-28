output "node_group_1_role" {
  value = module.eks.eks_managed_node_groups["one"].iam_role_name
}

# output "node_group_2_role" {
#   value = module.eks.eks_managed_node_groups["two"].iam_role_name
# }

# output "node_group_3_role" {
#   value = module.eks.eks_managed_node_groups["three"].iam_role_name
# }

output "oidc_provider" {
    description = "OIDC Provider for the cluster"
    value = module.eks.oidc_provider
}