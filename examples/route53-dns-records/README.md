# Assigning CNAME and Route 53 Alias to Vault HA cluster

*Before using you need to create or check name a public Route 53 Zone in your AWS account and set it it [variables.tf](variables.tf)*

## Usage

Enter next commands to run this example:

```shell
$ terraform init
$ terraform apply
```

After applying Vault HA cluster will available in the next domains:

```
CNAME: http://cname.example.io:443
Alias: http://alias.example.io:443
```

\* where `example.io` is your Route 53 zone

**ATTENTION! Some resources cannot be covered by Amazon Free Tier or not Free usage and cost a money so after running this example should destroy all resources created previously**

```shell
$ terraform destroy
```
