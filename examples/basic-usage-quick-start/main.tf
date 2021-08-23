provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=master"

  # the name that will appear for all resources and tags associated with 
  # the cluster. Convenient to test multiple clusters in the same region
  cluster_name = "vault-ha-basic"

  # count of nodes in a cluster, by default values this is equal to 3 
  # so here this setting can be omitted. It was placed here for clarity
  cluster_count = 3

  # type of EC2 instance for each node. You can choose t2.micro if you 
  # have a newly created AWS account with 12 months of free usage. 
  # For t2.micro you have up to 750 hours for free in a month so 3 nodes 
  # can be used for 1/3 of the month. See https://aws.amazon.com/free/
  node_instance_type = "t3a.small"

  # enabling this feature provides a more convenient way to auto unseal 
  # Vault cluster by AWS KMS. Additional charge might be for AWS KMS see 
  # https://aws.amazon.com/kms/pricing/
  autounseal = true

  # by default cluster nodes are placed to the private subnets, that 
  # suppose no internet connections without NAT gateway, so instance 
  # can't access to Docker registry and download Vault image. 
  # By enabling this additional costs may be charged see 
  # https://aws.amazon.com/vpc/pricing/
  nat_enabled = true
}
