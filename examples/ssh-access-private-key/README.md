# Public SSH access to the instances by OpenSSH private key

*This example shows how to connect to the instances on public IPs by OpenSSH using static public and private **RSA** (**ECDSA**) pairs. This method should be used just for debugging. Try to avoid it on production.*

Example of **Terraform** code creates a **Vault** cluster in the *public subnet*, with **AWS Internet Gateway** for *public access* and different ways of provisioning an **OpenSSH** *public key* to the instances

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying a Terraform code you should get Cluster URL ([cluster_url](https://github.com/binlab/terraform-aws-vault-ha-raft#output_cluster_url)) and list of Internet Gateway IPs ([igw_public_ips](https://github.com/binlab/terraform-aws-vault-ha-raft#output_igw_public_ips))

```shell
...
Outputs:

cluster_url = http://tf-vault-public-ssh-alb-123456789.us-east-1.elb.amazonaws.com:443
igw_public_ips = [
  "3.123.123.123",
  "4.231.231.231",
  "5.12.13.14",
]
```

For connecting to the cluster nodes just enter in console\*:

- if you applied Terraform code with variable `ssh_key_source=filesystem`

    ```shell
    ssh core@"$(terraform output -json igw_public_ips | jq -r '.[0]')"
    ```

- if you applied Terraform code with variable `ssh_key_source=internal|external`

    ```shell
    ssh -i ~/.ssh/vault-ssh_rsa core@"$(terraform output -json igw_public_ips | jq -r '.[0]')"
    ```

\* you need to have the utility `jq` installed on your local machine, if you don't have it just replace manually command with an appropriate IP address from Terraform output

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
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vault"></a> [vault](#module\_vault) | github.com/binlab/terraform-aws-vault-ha-raft | master |

## Resources

| Name | Type |
|------|------|
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.vault_ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [http_http.outside_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [local_file.ssh_public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region name | `string` | `"us-east-1"` | no |
| <a name="input_restrict_ssh_port"></a> [restrict\_ssh\_port](#input\_restrict\_ssh\_port) | Determine to restrict connection to SSH port by AWS security group <br>just for request host IP | `bool` | `true` | no |
| <a name="input_ssh_key_source"></a> [ssh\_key\_source](#input\_ssh\_key\_source) | Determine external SSH key will be used or internal<br>internal \| external \| filesystem | `string` | `"external"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key in a HOME directory | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
| <a name="output_igw_public_ips"></a> [igw\_public\_ips](#output\_igw\_public\_ips) | List of Internet public IPs. If cluster nodes are determined to be <br>in the public subnet (Internet Gateway used) all external network <br>requests will be via public IPs assigned to the nodes. This list <br>can be used for configuring security groups of related services or <br>connect to the nodes via SSH on debugging |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
