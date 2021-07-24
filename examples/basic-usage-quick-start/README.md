# Example code of basic usage (Quick start)

*This example shows how to use [Vault module](https://github.com/binlab/terraform-aws-vault-ha-raft) from scratch with basic configuration by default. Some additional options were added for a fast start and each of them was documented. Recommended starting using module from here.*

This example **Terraform** code creates a **Vault** cluster with **3 nodes**, with auto unseal by **AWS KMS** and **AWS NAT Gateway** *enabled*

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying a Terraform code you should get Cluster URL [cluster_url](https://github.com/binlab/terraform-aws-vault-ha-raft#output_cluster_url). By default, without\* [configuring certificate by ACM](https://github.com/binlab/terraform-aws-vault-ha-raft/blob/master/examples/acm-public-certificate/) it will looks like:

```shell
...
Apply complete! Resources: 70 added, 0 changed, 0 destroyed.

Outputs:

cluster_url = http://tf-vault-ha-basic-alb-123456789.us-east-1.elb.amazonaws.com:443

```

**Next step:** the initializing process detailed described [here](https://github.com/binlab/terraform-aws-vault-ha-raft/blob/master/docs/initializing-newly-created-cluster.md)

\* *you can configure and use **Vault** cluster without a certificate, but this is strongly **NOT RECOMMENDED** for production usage. How to configure certificate you can read [here](https://github.com/binlab/terraform-aws-vault-ha-raft/blob/master/examples/acm-public-certificate/)*

**ATTENTION! Some resources cannot be covered by Amazon Free Tier or not Free usage and cost a money so after running this example should destroy all resources created previously**

```shell
$ terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vault"></a> [vault](#module\_vault) | github.com/binlab/terraform-aws-vault-ha-raft | v0.1.8 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region name | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
