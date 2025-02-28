output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi_role.arn
}

output "eks_aws_caller" {
  value = "${data.aws_caller_identity.current.arn}:oidc-provider/${var.oidc_provider}"
}