# Assigning module's VPC to external resources in this example to a Bastion host

*This example shows how to use VPC created in a module for assigning external resources. 
In this case, the **Bastion** host https://github.com/binlab/terraform-aws-bastion will be assigned.
Useful for debugging without having to expose instances to a Public subnet.
Before using you need to check or create a SSH key your machine and set it it [variables.tf](variables.tf)
Default value `~/.ssh/id_rsa.pub` specifies a standard path and name for OpenSSH 
client mostly for Linux and macOS but might need to be configured before.*

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying you can use **Bastion** as a **Jump** host, for example:

```shell
$ ssh -J core@1.2.3.4 core@node0.vault.int
```

Or enter on **Bastion** and use **Vault** nodes in a local network, for example:

```shell
$ curl -k https://node0.vault.int:8200/ui/vault/auth?with=token
```

\* where `1.2.3.4` can be found in `bastion_host` output

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
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | github.com/binlab/terraform-aws-bastion | v0.1.5 |
| <a name="module_vault"></a> [vault](#module\_vault) | github.com/binlab/terraform-aws-vault-ha-raft | v0.1.8 |

## Resources

| Name | Type |
|------|------|
| [local_file.ssh_public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region name | `string` | `"us-east-1"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key in a HOME directory | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_host"></a> [bastion\_host](#output\_bastion\_host) | Bastion public host (Public IP) |
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
