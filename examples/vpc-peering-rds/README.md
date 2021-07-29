# VPC Peering different networks - in this example Vault HA and RDS Database

This example shows how to connect different **VPC** networks for bi-directional visibility a local resources.
Use cases: you have an **RDS** database (or other internal resources) which not a public accessible from **Internet** network for security reasons and you need setup **Vault Database Secret Engine** to generate temporary secrets. Or vise versa, the application needs to access a **Vault Cluster** from a **Private** network without heeds to expose outside.

*\* In this example, the **Bastion** host https://github.com/binlab/terraform-aws-bastion will be assigned for connecting to Vault instances just for the demo, and might not be needed on production.
Before using you need to check or create an SSH key your machine and set it [variables.tf](variables.tf)
Default value `~/.ssh/id_rsa.pub` specifies a standard path and name for **OpenSSH** 
client mostly for **Linux** and **macOS** but might need to be configured before.*

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying enter to **Vault Node0** via **Bastion** as a **Jump** host, for example:

```shell
$ ssh -J core@1.2.3.4 core@node0.vault.int
```

Then you can check visibility an **RDS** endpoint from **Vault Cluster VPC**, for example:

```shell
$ ncat rds.c1oqcheqlzat.us-east-1.rds.amazonaws.com 3306
```

Where:
  - `1.2.3.4` can be found in `bastion_host` output 
  - `rds.c1oqcheqlzat.us-east-1.rds.amazonaws.com` and `3306` can be found in `rds_endpoint` output 

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
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | github.com/binlab/terraform-aws-bastion | v0.1.5 |
| <a name="module_vault"></a> [vault](#module\_vault) | github.com/binlab/terraform-aws-vault-ha-raft | v0.1.8 |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_route.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_peering_connection.vault_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_availability_zones.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [local_file.ssh_public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region name | `string` | `"us-east-1"` | no |
| <a name="input_main_vpc_cidr"></a> [main\_vpc\_cidr](#input\_main\_vpc\_cidr) | Main VPC CIDR created separately. Block sizes must be between a <br>/16 netmask and /28 netmask for AWS. For example: <br>`10.0.0.0/16-10.0.0.0/28`,<br>`172.16.0.0/16-172.16.0.0/28`,<br>`192.168.0.0/16-192.168.0.0/28` | `string` | `"10.0.0.0/16"` | no |
| <a name="input_main_vpc_subnet_cidr"></a> [main\_vpc\_subnet\_cidr](#input\_main\_vpc\_subnet\_cidr) | CIDR block for VPC subnets, must be canonical form, be in the same <br>network with VPC and non-overlapping with other subnets. For example:<br>subnet `/25`, (e.g. `172.31.31.0/25`) can contain up to 16 subnets <br>with a mask `/28` (subnet mask must be not less than `/28` for AWS) | `string` | `"10.0.0.0/25"` | no |
| <a name="input_main_vpc_subnet_mask"></a> [main\_vpc\_subnet\_mask](#input\_main\_vpc\_subnet\_mask) | Size of VPC subnets. The subnet mask must be not less than `/28` <br>for AWS. Mask /28 can contain up to 16 IP addresses but AWS reserved <br>5 addresses so 11 available for user. More: <br>https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html | `number` | `28` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key in a HOME directory | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_vault_vpc_cidr"></a> [vault\_vpc\_cidr](#input\_vault\_vpc\_cidr) | VPC CIDR assigned to Vault cluster | `string` | `"172.31.31.0/24"` | no |
| <a name="input_vault_vpc_private_subnets"></a> [vault\_vpc\_private\_subnets](#input\_vault\_vpc\_private\_subnets) | VPC private subnets assigned to Vault cluster | `set(string)` | <pre>[<br>  "172.31.31.128/28",<br>  "172.31.31.144/28",<br>  "172.31.31.160/28"<br>]</pre> | no |
| <a name="input_vault_vpc_public_subnets"></a> [vault\_vpc\_public\_subnets](#input\_vault\_vpc\_public\_subnets) | VPC public subnets assigned to Vault cluster | `set(string)` | <pre>[<br>  "172.31.31.0/28",<br>  "172.31.31.16/28",<br>  "172.31.31.32/28"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_host"></a> [bastion\_host](#output\_bastion\_host) | Bastion public host (Public IP) |
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | RDS endpoint (hostname with a port in format host:port) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
