# Module to create a VPC

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.19.0"

    # Configure VPC Name
    name = var.vpc_name

    # Configure VPC CIDR Address
    # Ideally you would want to choose the subnets automatically based on whats possible rather than hardcoding the CIDR in
    cidr = var.vpc_cidr

    # Configure AZs to use for our subnets, remember each subnet can only span a single AZ
    # Use a different AZ for each subnet for better availability
    azs = var.vpc_azs

    # Need 3 availability zones for each subnet type (9 Subnets total, 3 AZs for each subnet type)
    # 1-a, 1-b, 1-c for each type of subnet type
    public_subnets = var.vpc_public_subnets
    private_subnets = var.vpc_private_subnets
    intra_subnets = var.vpc_intra_subnets

    # Enable a NAT gateway to allow non public subnets to access the internet
    enable_nat_gateway = false

    # Enable DNS Hostnames for Kubernetes
    enable_dns_hostnames = false

    # Tags are required for each subnet type so that it can be identified and used in Kubernetes
    public_subnet_tags = var.vpc_public_subnet_tags
    private_subnet_tags = var.vpc_private_subnet_tags
    intra_subnet_tags = var.vpc_intra_subnet_tags
}

# Creating Security Group for the VPC
resource "aws_security_group" "vpcSecurityGroup" {
    name = "vpcSecurityGroup"
    description = "Allow ICMP traffic, TCP, UDP and Egress Outbound Traffic"
    # Attach to VPC
    vpc_id = module.vpc.vpc_id

    tags = {
        Name = "vpcSecurityGroup"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
    security_group_id = aws_security_group.vpcSecurityGroup.id
    cidr_ipv4 = var.vpc_cidr # Is this the correct way to call this?
    from_port = -1 # We want to allow all ports for ICMP traffic
    ip_protocol = "icmp"
    to_port = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls" {
    security_group_id = aws_security_group.vpcSecurityGroup.id
    # CIDR Block we can allow this traffic from, we want to only allow from within the VPC for internal communication
    cidr_ipv4 = var.vpc_cidr
    from_port = 80
    ip_protocol = "tcp"
    to_port = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_udp" {
    security_group_id = aws_security_group.vpcSecurityGroup.id
    # CIDR Block we can allow this traffic from, we want to only allow from within the VPC for internal communication
    cidr_ipv4 = var.vpc_cidr
    from_port = 80
    ip_protocol = "udp"
    to_port = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_out" {
  security_group_id = aws_security_group.vpcSecurityGroup.id
  # We want to allow all traffic outbound
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}