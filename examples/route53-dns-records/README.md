# Assigning CNAME and Route 53 Alias to Vault HA cluster

*Before using you need to create or check name a public Route 53 Zone in your AWS account and set it it [variables.tf](variables.tf)*

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying you will see:

```shell
...
Apply complete! Resources: 72 added, 0 changed, 0 destroyed.

Outputs:

cluster_url_alb = http://tf-vault-route53-alb-123456789.us-east-1.elb.amazonaws.com:443
cluster_url_alias = http://alias.example.io:443
cluster_url_cname = http://cname.example.io:443
```

Vault HA cluster will available in the next domains:

```
ALB:   http://tf-vault-route53-alb-123456789.us-east-1.elb.amazonaws.com:443
CNAME: http://cname.example.io:443
Alias: http://alias.example.io:443
```

\* where `example.io` is your Route 53 zone

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
| [aws_route53_record.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"us-east-1"` | no |
| <a name="input_route53_zone"></a> [route53\_zone](#input\_route53\_zone) | Name of existing public Route 53 Zone | `string` | `"example.io"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_url_alb"></a> [cluster\_url\_alb](#output\_cluster\_url\_alb) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
| <a name="output_cluster_url_alias"></a> [cluster\_url\_alias](#output\_cluster\_url\_alias) | Cluster public URL assesible by Route53 Alias |
| <a name="output_cluster_url_cname"></a> [cluster\_url\_cname](#output\_cluster\_url\_cname) | Cluster public URL assesible by Route53 CNAME |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
