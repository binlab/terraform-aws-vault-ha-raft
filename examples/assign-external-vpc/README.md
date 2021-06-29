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
