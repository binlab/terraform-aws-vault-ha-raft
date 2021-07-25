# Adding public certificate and domain by ACM and Route53

*Before using you need to create or check name a public Route 53 Zone in your AWS account and set it it [variables.tf](variables.tf) or add file `*.auto.tfvars` see details [here](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files)*

By this example, you create a **Vault** cluster with your *public domain* provided by **Route53** and *trusted certificate* provided by **AWS ACM**

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying you will see next output:

```shell
...
Apply complete! Resources: 73 added, 0 changed, 0 destroyed.

Outputs:

cluster_url = https://vault.example.io:443
```

\* where `example.io` is your Route 53 zone

**Next step:** the initializing process detailed described [here](https://github.com/binlab/terraform-aws-vault-ha-raft/blob/master/docs/initializing-newly-created-cluster.md)

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
| [aws_acm_certificate.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_route53_record.acm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"us-east-1"` | no |
| <a name="input_domain_prefix"></a> [domain\_prefix](#input\_domain\_prefix) | Domain prefix for a Vault cluster | `string` | `"vault"` | no |
| <a name="input_route53_zone"></a> [route53\_zone](#input\_route53\_zone) | Name of existing public Route 53 Zone | `string` | `"example.io"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
