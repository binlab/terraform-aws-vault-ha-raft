# Change AMI on worked cluster

In some cases, you might need to replace AMI on your worked cluster, e.g. for debugging, for use your own created by [Packer](https://www.packer.io/), or in case of [this issue](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/48)

But nodes of the cluster are protected by `lifecycle policy` with an `ami` change for preventing re-creating nodes in each time of the new release of **AMI**. Since interpolation not allowed for lifecycle metadata, so no way to move this option to variables yet. Read more about this [here](https://www.terraform.io/docs/configuration-0-11/resources.html#meta-parameters) and [here](https://github.com/hashicorp/terraform/issues/3116). So it need a manual work with a source of module. To do this you have two options:

- clone Terraform module on your local system and change a call to the module by `source` with full local path

- change directly a sources in a local copy of module in `.terraform/modules/vault/` 

then you just need to comment row https://github.com/binlab/terraform-aws-vault-ha-raft/blob/master/ec2.tf#L45

```terraform
  ...
  lifecycle {
    ignore_changes = [
      # ami,
      # Added due: 
      # https://github.com/terraform-providers/terraform-provider-aws/issues/729
      volume_tags,
    ]
  }
  ...
```

after that you can configure a AMI by [ami_image](https://github.com/binlab/terraform-aws-vault-ha-raft#input_ami_image)