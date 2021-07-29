# Assigning Vault cluster to inside an already created (external) AWS VPC

*This example takes predefined AWS VPC which exists in each AWS account and can't be deleted. For obtaining `vpc_id` we use data resource `aws_vpc` with `default = true`. For testing with other networks please note network should exist *before* `terraform apply` otherwise a may occur error `Error: Invalid count argument`. This means you can't use `resource "aws_vpc"` in one stage*

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying you will see `cluster_url` output, for example:

```shell
...
Apply complete! Resources: 40 added, 0 changed, 0 destroyed.

Outputs:

cluster_url = http://tf-vault-ext-vpc-alb-xxxxxxxxx.us-east-1.elb.amazonaws.com:443
```

**ATTENTION! Some resources cannot be covered by Amazon Free Tier or not Free usage and cost a money so after running this example should destroy all resources created previously**

```shell
$ terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vault"></a> [vault](#module\_vault) | github.com/binlab/terraform-aws-vault-ha-raft | v0.1.8 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region name | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
