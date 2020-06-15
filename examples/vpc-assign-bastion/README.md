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
