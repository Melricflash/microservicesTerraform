# Creating IAM Roles and using assume_role_policy for federated OIDC authentication

# Automatically retrieve the account details for the running user
data "aws_caller_identity" "current" {}

# Create the role, then attach a policy later
resource "aws_iam_role" "melric_external_dns" {
  name = "melric-external-dns"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:issue-microservices:external-dns"
          }
        }
      }
    ]
  })
}

#arn:aws:iam::

resource "aws_iam_role" "melric_ebs_csi_role" {
  name = "melric_ebs_csi_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:issue-microservices:ebs-csi"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "melric_sqs_role" {
  name = "melric-sqs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:issue-microservices:frontend-service-account" # Make a note that this needs to be the name of the service account used in K8s
          }
        }
      }
    ]
  })
}

# Splitting the SQS role into two
resource "aws_iam_role" "melric_sqs_consume_role" {
  name = "melric-sqs-role-consume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:issue-microservices:backend-service-account" 
          }
        }
      }
    ]
  })
}

# K8s can only assume a single service account at a time, combine SES and SQS policies to one role
resource "aws_iam_role" "melric_ses_sqs_role" {
  name = "melric-ses-sqs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:issue-microservices:ses-backend-service-account" 
          }
        }
      }
    ]
  })
  
}

resource "aws_iam_role" "melric-iam-eks-role-lb-controller" {
  name = "melric-iam-eks-role-lb-controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
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
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com",
            "${var.oidc_provider}:sub" = "system:serviceaccount:issue-microservices:eks-melric"
          }
        }
      }
    ]
  })
}



# Attaching the policies to the roles
resource "aws_iam_role_policy_attachment" "external_dns_policy_attach" {
    role = aws_iam_role.melric_external_dns.name
    policy_arn = aws_iam_policy.route53_ExternalDNS.arn
}


resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
    role = aws_iam_role.melric_ebs_csi_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" # Managed by AWS
}

# Attach Managed ECR Access policy to EKS Workloads role
resource "aws_iam_role_policy_attachment" "ecr_policy_attach" {
    role = aws_iam_role.role_eks_melriclabs.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}


# We want to attach multiple policies for SQS
resource "aws_iam_role_policy_attachment" "sqs_create_policy_attach" {
    role = aws_iam_role.melric_sqs_role.name
    policy_arn = aws_iam_policy.SQS_create_message.arn
}

# Attach get attributes for SQS
resource "aws_iam_role_policy_attachment" "sqs_get_attributes_policy_attach" {
    role = aws_iam_role.melric_sqs_role.name
    policy_arn = aws_iam_policy.SQS_get_queue_attributes.arn
}

resource "aws_iam_role_policy_attachment" "sqs_get_queue_url_policy_attach" {
    role = aws_iam_role.melric_sqs_role.name
    policy_arn = aws_iam_policy.SQS_get_queue_url.arn
}

resource "aws_iam_role_policy_attachment" "sqs_bedrock_policy_attach" {
  role = aws_iam_role.melric_sqs_role.name
  policy_arn = aws_iam_policy.bedrock_policy.arn
}

resource "aws_iam_role_policy_attachment" "sqs_read_policy_attach" {
    role = aws_iam_role.melric_sqs_consume_role.name
    policy_arn = aws_iam_policy.SQS_read_message.arn
}

resource "aws_iam_role_policy_attachment" "sqs_delete_policy_attach" {
    role = aws_iam_role.melric_sqs_consume_role.name
    policy_arn = aws_iam_policy.SQS_delete_message.arn
}

resource "aws_iam_role_policy_attachment" "sqs_ses_policy_attach" {
  role = aws_iam_role.melric_ses_sqs_role.name
  policy_arn = aws_iam_policy.SQS_SES_policy.arn
}

# Provide OIDC and it will create the roles and attach the policies automatically for the LB controller and EKS workloads roles?

# Attach LB policy to the role
resource "aws_iam_role_policy_attachment" "load_balancer_policy_attach" {
    role = aws_iam_role.melric-iam-eks-role-lb-controller.name
    policy_arn = aws_iam_policy.load_balancer_policy.arn
}


# EKS node group policy assignment

# Node Group 1
resource "aws_iam_role_policy_attachment" "node_group_1_ssm_policy_attach" {
    role = var.node_group_1_role
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "node_group_1_ecr_read_policy_attach" {
    role = var.node_group_1_role
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# # Node Group 2
# resource "aws_iam_role_policy_attachment" "node_group_2_ssm_policy_attach" {
#     role = var.node_group_2_role
#     policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_role_policy_attachment" "node_group_2_ecr_read_policy_attach" {
#     role = var.node_group_2_role
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# # Node Group 3
# resource "aws_iam_role_policy_attachment" "node_group_3_ssm_read_policy_attach" {
#     role = var.node_group_3_role
#     policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_role_policy_attachment" "node_group_3_ecr_read_policy_attach" {
#     role = var.node_group_3_role
#     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }