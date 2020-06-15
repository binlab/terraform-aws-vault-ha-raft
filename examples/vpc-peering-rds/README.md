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
