# Creating IAM Roles and using assume_role_policy for federated OIDC authentication


# Create the role, then attach a policy later
resource "aws_iam_role" "external_dns" {
  name = "external_dns"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_caller_identity_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "ebs_csi_role" {
  name = "ebs_csi_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_caller_identity_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "sqs_role" {
  name = "sqs_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_caller_identity_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "iam_eks_role_lb_controller" {
  name = "iam_eks_role_lb_controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_caller_identity_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "role_eks_melriclabs" {
  name = "role_eks_melriclabs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_caller_identity_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

# Attaching the policies to the roles
resource "aws_iam_role_policy_attachment" "external_dns_policy_attach" {
    role = aws_iam_role.external_dns.name
    policy_arn = aws_iam_policy.route53_ExternalDNS.arn
}


resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
    role = aws_iam_role.ebs_csi_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" # Managed by AWS
}

# Attach Managed ECR Access policy to EKS Workloads role
resource "aws_iam_role_policy_attachment" "ecr_policy_attach" {
    role = aws_iam_role.role_eks_melriclabs.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}


# We want to attach multiple policies for SQS
resource "aws_iam_role_policy_attachment" "sqs_create_policy_attach" {
    role = aws_iam_role.sqs_role.name
    policy_arn = aws_iam_policy.SQS_create_message.arn
}

resource "aws_iam_role_policy_attachment" "sqs_read_policy_attach" {
    role = aws_iam_role.sqs_role.name
    policy_arn = aws_iam_policy.SQS_read_message.arn
}

resource "aws_iam_role_policy_attachment" "sqs_delete_policy_attach" {
    role = aws_iam_role.sqs_role.name
    policy_arn = aws_iam_policy.SQS_delete_message.arn
}


# Provide OIDC and it will create the roles and attach the policies automatically for the LB controller and EKS workloads roles?

# Attach LB policy to the role
resource "aws_iam_role_policy_attachment" "load_balancer_policy_attach" {
    role = aws_iam_role.iam_eks_role_lb_controller.name
    policy_arn = aws_iam_policy.load_balancer_policy.arn
}