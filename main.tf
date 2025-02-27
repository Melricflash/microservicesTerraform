# Initialise the VPC module
module "vpc" {
    source = "./modules/vpc"
}

module "iam" {
    source = "./modules/iam"
}

module "sqs" {
    source = "./modules/sqs"
}