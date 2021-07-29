# Development and Debugging Sandbox

*This is an example created for the development of new features, debugging clusters, or fixing bugs. All configuration and outputs are very specific for development purposes and specific for person who well known with a Terraform, Linux and Shell, there will not be a lot of details and comments so not recommended to apply if you are a beginner in Terraform. Some examples and information might to useful for involving to process of development and contribution. If you interesting with this recommended use this example.*

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform plan
$ terraform apply
```

After applying you should see all needed information, for example:

```shell
...
Apply complete! Resources: 72 added, 0 changed, 0 destroyed.

Outputs:

bastion_host = 18.207.181.20
cluster_url = http://tf-vault-debug-alb-123456789.us-east-1.elb.amazonaws.com:443
ssh_connection_commands = {
  "node0" = "ssh -o StrictHostKeyChecking=no -J core@18.207.181.20 core@node0.vault.int -t 'sudo su'"
  "node1" = "ssh -o StrictHostKeyChecking=no -J core@18.207.181.20 core@node1.vault.int -t 'sudo su'"
  "node2" = "ssh -o StrictHostKeyChecking=no -J core@18.207.181.20 core@node2.vault.int -t 'sudo su'"
}
```

## Useful CLI commands and tricks

- Delete row from `known_hosts`

    ```shell
    sed -i '/node0.vault.int/d' ~/.ssh/known_hosts
    ```

- Show last 40 log records in reverse order by `journalctl`

    ```shell
    journalctl --utc -a -u vault.service -r -n 40
    ```
    
- Follow a logs in realtime by `journalctl`

    ```shell
    journalctl --utc -a -u vault.service -f
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
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | github.com/binlab/terraform-aws-bastion | v0.1.5 |
| <a name="module_vault"></a> [vault](#module\_vault) | github.com/binlab/terraform-aws-vault-ha-raft | master |

## Resources

| Name | Type |
|------|------|
| [local_file.ssh_public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region name | `string` | `"us-east-1"` | no |
| <a name="input_cluster_count"></a> [cluster\_count](#input\_cluster\_count) | Count of Nodes in Cluster | `number` | `3` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key in a HOME directory | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_host"></a> [bastion\_host](#output\_bastion\_host) | Bastion public host (Public IP) |
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
| <a name="output_ssh_connection_commands"></a> [ssh\_connection\_commands](#output\_ssh\_connection\_commands) | Fast CLI commands for connection to nodes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
