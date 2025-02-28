module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "20.33.1"

    cluster_name = var.cluster_name
    cluster_version = var.cluster_version

    # Allow public access to the API endpoint
    cluster_endpoint_public_access = true


    # Enable admin permissions for cluster creator
    enable_cluster_creator_admin_permissions = true
    # Authentication Mode
    authentication_mode = var.eks_authentication_mode

    # Associate Cluster with VPC
    vpc_id = var.vpc_id

    # Control Plane across intra subnets
    control_plane_subnet_ids = var.vpc_intra_subnets

    # Worker nodes across private subnets
    subnet_ids = var.vpc_private_subnets

    # Create an OIDC provider
    enable_irsa = true

    # Setting up cluster addons
    cluster_addons = {
        coredns = {most_recent = true} # Kubernetes Service Discovery

        kube-proxy = {most_recent = true} # Network Proxying

        vpc-cni = {most_recent = true} # Networking
        
        aws-ebs-csi-driver = { # Persistent Storage
            service_account_role_arn = var.ebs_csi_role_arn # Use the role arn for access
            most_recent = true 
        }
    }

    eks_managed_node_group_defaults = {
        ami_type = "AL2023_x86_64_STANDARD" # default AMI type for cluster
    }

    # Deploying EKS Managed Node Groups
    eks_managed_node_groups = {

        one = {
            name = "melric_node_group_1"
            # Set the instance type for the node group
            instance_types = var.node_instance_type

            # Capacity for the node group
            min_size = var.node_min_size
            max_size = var.node_max_size
            desired_size = var.node_desired_size

            # Important! Documentation says subnet must have kubernetes.io/cluster/CLUSTER_NAME
            # Note it requires a list 
            subnet_ids = [var.vpc_private_subnets[0]] # Associate to private subnet 1?

            # Attaching IAM Policies
            # Export the group iam role, and attach policy to it inside IAM

            # Configure Storage, we can use launch template to specify this
            # We want to use gp2 storage and 20GB volume size
            launch_template = {
                root_volume_type = "gp2"
                root_volume_size = 20
            }

        }

        # two = {
        #     name = "melric_node_group_2"

        #     instance_types = var.node_instance_type

        #     min_size = var.node_min_size
        #     max_size = var.node_max_size
        #     desired_size = var.node_desired_size

        #     subnet_ids = [var.vpc_private_subnets[1]] # Associate to private subnet 2

        #     # Attach policies to this node group inside IAM module

        #     # Configure Storage
        #     launch_template = {
        #         root_volume_type = "gp2"
        #         root_volume_size = 20
        #     }
        # }

        # three = {
        #     name = "melric_node_group_3"

        #     instance_types = var.node_instance_type

        #     min_size = var.node_min_size
        #     max_size = var.node_max_size
        #     desired_size = var.node_desired_size

        #     subnet_ids = [var.vpc_private_subnets[2]] # Associate to private subnet 3

        #     # Attach policies to this node group inside IAM module
        # }


    }
}