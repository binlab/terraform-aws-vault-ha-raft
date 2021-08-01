# Example of use External AWS KMS Key for internal Auto Unseal configuration

*This example shows how to use [Vault module](https://github.com/binlab/terraform-aws-vault-ha-raft) with external AWS KMS Key for auto unseal by internal resources. Can be useful in case of data migration by snapshots or backups. Or for use already managed KMS Key by external configuration.*

This example **Terraform** code creates a **Vault** cluster with **3 nodes**, with auto unseal by **AWS KMS** with external KMS Key created be external resource

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform plan
$ terraform apply
```

After applying a Terraform code you should get Cluster URL [cluster_url](https://github.com/binlab/terraform-aws-vault-ha-raft#output_cluster_url).

```shell
...
Outputs:

cluster_url = http://tf-vault-kms-alb-123456789.us-east-1.elb.amazonaws.com:443
kms_key_arn = arn:aws:kms:us-east-1:727727727272:key/f0f48d4d-b3e1-4eca-b6d4-dd9be5f3d7b3
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
| <a name="module_vault"></a> [vault](#module\_vault) | github.com/binlab/terraform-aws-vault-ha-raft | master |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region name | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of AWS KMS Key. It can return arn of internal created key or <br>just forward arn of an external key if it provided by "kms\_key\_arn" <br>variable. It will return null if "autounseal=true". |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
