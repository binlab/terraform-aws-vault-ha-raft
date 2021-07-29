# Hashicorp Vault HA cluster based on Raft Consensus Algorithm

<p align="center">
  <a href="https://github.com/binlab/terraform-aws-vault-ha-raft/blob/LICENSE"><img alt="License" src="https://img.shields.io/github/license/binlab/terraform-aws-vault-ha-raft?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-vault-ha-raft/tags"><img alt="GitHub tag" src="https://img.shields.io/github/v/tag/binlab/terraform-aws-vault-ha-raft?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-vault-ha-raft/releases"><img alt="GitHub release" src="https://img.shields.io/github/v/release/binlab/terraform-aws-vault-ha-raft?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-vault-ha-raft/commits"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/binlab/terraform-aws-vault-ha-raft?logo=github"></a>
  <a href="https://github.com/binlab/terraform-aws-vault-ha-raft/commits"><img alt="GitHub commit activity" src="https://img.shields.io/github/commit-activity/m/binlab/terraform-aws-vault-ha-raft?logo=github"></a>
</p>
<p align="center">
  <img alt="languages Count" src="https://img.shields.io/github/languages/count/binlab/terraform-aws-vault-ha-raft">
  <img alt="Languages Top" src="https://img.shields.io/github/languages/top/binlab/terraform-aws-vault-ha-raft">
  <img alt="Code Size" src="https://img.shields.io/github/languages/code-size/binlab/terraform-aws-vault-ha-raft">
  <img alt="Repo Size" src="https://img.shields.io/github/repo-size/binlab/terraform-aws-vault-ha-raft">
</p>

<img width="600" alt="Vault Logo" src="https://raw.githubusercontent.com/hashicorp/vault/f22d202cde2018f9455dec755118a9b84586e082/Vault_PrimaryLogo_Black.png">

Vault HA cluster is based on [Raft Storage Backend](https://www.vaultproject.io/docs/configuration/storage/raft) announced **tech preview** on [1.2.0 (July 30th, 2019)](https://github.com/hashicorp/vault/blob/master/CHANGELOG.md#120-july-30th-2019), introduced a **beta** on [1.3.0 (November 14th, 2019))](https://github.com/hashicorp/vault/blob/master/CHANGELOG.md#13-november-14th-2019) and promoted **out of beta** on [1.4.0 (April 7th, 2020)](https://github.com/hashicorp/vault/blob/master/CHANGELOG.md#140-april-7th-2020)

>The Raft storage backend is used to persist Vault's data. Unlike other storage backends, Raft storage does not operate from a single source of data. Instead all the nodes in a Vault cluster will have a replicated copy of Vault's data. Data gets replicated across the all the nodes via the [Raft Consensus Algorithm](https://raft.github.io).
> - **High Availability** – the Raft storage backend supports high availability.
> - **HashiCorp Supported** – the Raft storage backend is officially supported by HashiCorp.


## Key features:

- Can be run with low consumption of costs or even just on *AWS Free Tier*
- No external dependencies like **Consul**, **ETCD**, database, etc for storing data
- No need additional provisioning tools like **Ansible**, **Chief** of **Puppet**, all based on clear **Terraform**
- Module fully independent with zero-external resources dependencies and just optional like `ACM` for `HTTPS` etc
- Provisioning based on **CoreOS ignitions** so very fast, declarative and predictable 
- Fast and easily manual creating snapshots (*backups*) from [Vault UI](docs/raft-manual-snapshots.md) (thanks **Raft** [implementations](https://www.vaultproject.io/docs/commands/operator/raft))
- Integrated auto backups of data by **Amazon snapshots** and fully configurable scheduler (*false by default*)
- Integrated optional [auto-unseal](https://www.vaultproject.io/docs/configuration/seal) with built-in **AWS KMS** provisioning, external [AWS KMS](https://www.vaultproject.io/docs/configuration/seal/awskms) or [Transit](https://www.vaultproject.io/docs/configuration/seal/transit) secret backend by another **Vault**
- **Vault Raft data** is storing on separate **EBS** volumes independent from a root filesystem
- Easily increase and decrease the count of nodes without losing of data just by running `terraform apply` (*with some downtime*)
- The cluster can be running-up from just one node to N-nodes with proportional distribution by availability zones in a region
- No data lost happens even all instances will be terminated by mistake (just need to redeploy by **Terraform** for restoring a cluster)
- Possible to upgrade or downgrade a **Vault** version across all cluster without losing of data (*with some downtime*)
- Communication between peers (nodes) encrypted by **TLS v1.2+** with certificate-based client authentication by **RSA-2048**\* (bidirectional **TLS** encryption and authentication)
- Communication between cluster and **ALB** (*Load Balancer*) encrypted by **TLS v1.2+**
- Free Amazon certificate (`ACM`) can be assigned to **ALB** for *client-server* encryption
- By default, all nodes are hidden in private subnet and just one port on `ALB` accessible outside (best **AWS** security practice)
- Optional generation `SSH` pair (**RSA-4096**\*) and assigned to nodes (not recommended, better to provisioning external `SSH` public key)
- Access to instances by `SSH` also can by provisioning **Root CA**\* *certificate* and *principals*
- Provided assigning external own **Root CA**\* for cases when **Vault** need secure communicate with internal infrastructure
- For better security provided support for `disable_mlock=false` by default
- Optional can enable assigning public network for all nodes. `SSH` and `HTTPS` port will be available publicly (*for debugging and development only*)
- Implemented debugging options with full audit of all configurations files and certificates which the cluster deploying on (*for debugging and development only*)

\* *looking [here](#limitations) some limitations regarding AWS provisioning*


## Why?

Why not use a Kubernetes or other current cluster? For this, I can name a few reasons:  
1. **Independence.** For creating infrastructure as a code by Terraform (for example the same cluster) we need storage for storing secret input parameters (passwords, IPs, private data) and outputs (tokens, endpoints, passwords). For this very convenient to use a Vault.
2. **Stability.** Cluster is an additional layer of abstraction across all EC2 instances. Much better using native methods of deploying.
3. **Security.** Vault might be storing very secret and sensitive data. Putting this data together with publicly available services may carry potential risks of leaks. In this case, we can deploy a cluster totally independent even in a separate AWS account with access to which is limited to a few people.
4. **Lightweight.** Sometimes we need a very lightweight and cheap Vault and at the same time very stable. E.g. just for auto-unseal another Vault.  


## **IMPORTANT**

- After Flatcar Container Linux [release 2905.2.0](https://kinvolk.io/flatcar-container-linux/releases/#release-2905.2.0) Vault cluster stop working due [rkt](https://www.openshift.com/learn/topics/rkt) deprecated, so all Vault module tags up to `v0.1.8` stopped work, more [#48](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/48). Please update module to latest version and check all the latest changes to compatibility with your configuration.


## AWS Permissions

For deploying you need a list of permissions. For beginners might be difficult to set up minimal need permissions, so here the list wildcard for main actions. For professional or those who interesting for high-level security and granular permissions looking this [AWS IAM Granular Permissions](docs/aws-iam-granular-permissions.md)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VaultHAProvisioning",
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "DLM:*",
        "elasticloadbalancing:*",
        "iam:*",
        "kms:*",
        "route53:*",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```

## Usage

__IMPORTANT:__ *The last code from master might need to temporary enable the option `nat_enabled` (access to external resources) at the first initialization since, during the creation of the cluster, the instance needs to get a docker image. An alternative could be placing the cluster on a public subnet*

The module can be deployed with almost default values of variables. For more details of the default values looking [here](#inputs)

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vault" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.8"

  cluster_name       = "vault-ha"
  node_instance_type = "t3a.small"
  autounseal         = true
  nat_enabled        = true
}

output "cluster_url" {
  value = module.vault_ha.cluster_url
}
```

*Then run:*

```shell
$ terraform init
$ terraform apply
```

*After deploying the process you should see:*

```shell
...
cluster_url = http://tf-vault-ha-alb-123456789.us-east-1.elb.amazonaws.com:443
$
```

*Then just open URL in a browser and [initialize the cluster](docs/initializing-newly-created-cluster.md)*

**ATTENTION! Some resources cannot be covered by Amazon Free Tier or not Free usage and cost a money so after running this example should destroy all resources created previously by next command:**

```shell
$ terraform destroy
```

## HOW TO

  1. [Initializing newly created cluster](docs/initializing-newly-created-cluster.md)
  1. [Raft manual snapshots (Init/Join/Backup/Restore)](docs/raft-manual-snapshots.md)
  1. [AWS IAM Granular Permissions](docs/aws-iam-granular-permissions.md)
  1. [Change AMI on worked cluster](docs/change-ami-on-worked-cluster.md)


## Examples

  1. [Basic usage (Quick start)](examples/basic-usage-quick-start/)
  1. [Public SSH access to the instances by OpenSSH private key](examples/ssh-access-private-key/)
  1. [Assigning CNAME and Route 53 Alias to Vault HA cluster](examples/route53-dns-records/)
  1. [Adding public certificate and domain by ACM and Route53](examples/acm-public-certificate/)
  1. [Assigning module's VPC to external resources e.g. Bastion host](examples/vpc-assign-bastion/)
  1. [VPC Peering different networks e.g. RDS Database](examples/vpc-peering-rds/)
  1. [Assigning Vault cluster to inside an already created (external) AWS VPC](examples/assign-external-vpc/)


## Troubleshooting

  See separate page [#troubleshooting](docs/troubleshooting.md)

  In case you encounter trouble that is not described in documentation or you cannot solve by your self please free to [open an issue](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/new)


## TODO

- [x] Add examples of use with different cases [#10](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/10)
- [ ] Hosted module on [Terraform Registry](https://registry.terraform.io) [#13](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/13)
- [ ] Add validation of input data in [variables.tf](variables.tf) 
- [ ] Add support **Fedora CoreOS** as [announced](https://coreos.com/os/docs/latest/cloud-config-deprecated.html) **CoreOS Container Linux** will reach its end of life on **May 26, 2020** and will no longer receive updates.
- [x] Remove external dependency - *VPC Module* - [#7](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/7)
- [x] Add support for external AWS VPC - [#4](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/4)
- [ ] Add an option to configure preferred AWS availability zones - [#36](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/36)
- [ ] Add configuration for an external Vault Audit Device via [syslog](https://www.vaultproject.io/docs/audit/syslog) or [socket](https://www.vaultproject.io/docs/audit/socket)
- [ ] *Third-party plugins* installation support
- [ ] Add optional opened `HTTP` port on **ALB** and setup redirect from `HTTP` to `HTTPS`. Canonical support 
- [x] Disable **NAT Gateway** by default (*for reducing costs consumptions and security improvement*) - [#27](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/27)
- [ ] Option to disable **Route 53** internal zone for (*reducing costs consumptions*)
- [ ] Add **EFS** storage support as a persistent **Raft** data storage
- [ ] Add option to disable creating an additional **EFS** (*for reducing costs consumptions*)
- [ ] Add option to store **Raft** data in a temporary memory (**RAM**) - **paranoid mode**
- [ ] Implement a provisioning internal **Intermediate CA**\* for signing nodes certificates
- [ ] Implement scheduler backup of data by embedded snapshot operator and storing to **S3 Bucket** (*reducing costs consumptions*)
- [ ] Replace creating **EC2 instances** to an autoscaling group (*might cost some limitation*)
- [ ] Auto-provisioning a cluster on the first installation with storing *Token* and *Unseal* keys by **GPG/PGP** or **Keybase**
- [ ] Add support of **OpenStack (OS)** Terraform module
- [ ] Add support of **Google Cloud Platform (GCP)** Terraform module
- [ ] Add support of **Microsoft Azure** Terraform module
- [ ] Add support of **AliCloud** Terraform module
- [ ] Add support of **Oracle Cloud (OCI)** Terraform module
- [ ] Add support of **Docker** by Terraform (for local development and testing) 
- [ ] Multi-regional support of cluster for super high availability
- [ ] Auto-deletion nodes in a cluster in time of decreasing count of nodes

\* *looking [here](#limitations) some limitations regarding AWS provisioning*


## Limitations

- Because **AWS** strictly limiting the size of **User Data** file, we can't put into the ignition file a very big certificate and keys. 

  > User data is limited to 16 KB, in raw form, before it is base64-encoded. The size of a string of length n after base64-encoding is ceil(n/3)*4. [source](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-add-user-data.html)

  So in this case we need to select the size experimentally. For exactly knows size of the file, you can use debug mode

- Requirements block and [versions.tf](versions.tf) may not accurately display a real minimum version of providers. A declared versions ware just an installed in the time of development and testing of the module and can give guaranties of working with this or higher version. If you use older versions of modules for some reason and can give some guarantees of working with it, please create an issue for downscaling some version to minimal needed.

- According to the [opened issue](https://github.com/terraform-providers/terraform-provider-aws/issues/729) be careful with Tags settings, any changes after creating the tags may have a trigger effect on the change of value. Until the problem is closed by the Terraform team, a [temporary workaround](https://github.com/binlab/terraform-aws-vault-ha-raft/blob/b12700faef08ec460fc341d5ad12d0ee575486f6/ec2.tf#L46) is applied and it is best to determine the tag names in advance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.53.0 |
| <a name="requirement_ignition"></a> [ignition](#requirement\_ignition) | >= 1.2.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.4.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 2.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.53.0 |
| <a name="provider_ignition"></a> [ignition](#provider\_ignition) | >= 1.2.1 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 1.4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 2.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dlm_lifecycle_policy.snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |
| [aws_ebs_volume.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.autounseal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.autounseal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.autounseal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_key.autounseal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_nat_gateway.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.int](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.int](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_volume_attachment.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [local_file.ca_cert](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.node_cert](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.node_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user_data](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_cert_request.node](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.node](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.core](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.node](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.coreos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.flatcar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.autounseal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.autounseal_sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshots_sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [ignition_config.node](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/config) | data source |
| [ignition_file.auth_principals_admin](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.auth_principals_core](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.ca_ssh_public_keys](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.ca_tls_public_keys](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.config](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.helper](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.node_ca](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.node_cert](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.node_key](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_file.sshd_config](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/file) | data source |
| [ignition_filesystem.data](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/filesystem) | data source |
| [ignition_systemd_unit.mount](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/systemd_unit) | data source |
| [ignition_systemd_unit.service](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/systemd_unit) | data source |
| [ignition_user.admin](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/user) | data source |
| [ignition_user.core](https://registry.terraform.io/providers/hashicorp/ignition/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_channel"></a> [ami\_channel](#input\_ami\_channel) | AMI filter for OS channel [stable/edge/beta/etc] | `string` | `"stable"` | no |
| <a name="input_ami_image"></a> [ami\_image](#input\_ami\_image) | Specific AMI image ID in current Avalability Zone e.g. [ami-123456]<br>If provided nodes will be run on it, for cases when image built by <br>Packer if set it will disable search images by "ami\_vendor" and <br>"ami\_channel". Note: Instance OS should support CoreOS Ignition <br>provisioning. To change on worked cluster you need some trick, more<br>https://github.com/binlab/terraform-aws-vault-ha-raft/blob/master/docs/change-ami-on-worked-cluster.md | `string` | `""` | no |
| <a name="input_ami_vendor"></a> [ami\_vendor](#input\_ami\_vendor) | AMI filter for OS vendor [coreos/flatcar] | `string` | `"flatcar"` | no |
| <a name="input_autounseal"></a> [autounseal](#input\_autounseal) | Option to enable/disable creating KMS key, IAM role, policy and <br>AssumeRole for autounseal by AWS. Instead of creating by module, <br>can be used external resources for autounseal or without it at all. <br>If set will disable "seal\_transit" and "seal\_awskms". | `bool` | `false` | no |
| <a name="input_aws_snapshots"></a> [aws\_snapshots](#input\_aws\_snapshots) | Option to enable/disable embedded snapshots by AWS | `bool` | `false` | no |
| <a name="input_aws_snapshots_interval"></a> [aws\_snapshots\_interval](#input\_aws\_snapshots\_interval) | Snapshot Interval. How often this lifecycle policy <br>should be evaluated. 2,3,4,6,8,12 or 24 are valid values | `number` | `24` | no |
| <a name="input_aws_snapshots_retain"></a> [aws\_snapshots\_retain](#input\_aws\_snapshots\_retain) | How many snapshots to keep. Must be an integer between 1 and 1000 | `number` | `7` | no |
| <a name="input_aws_snapshots_time"></a> [aws\_snapshots\_time](#input\_aws\_snapshots\_time) | A list of times in 24 hour clock format that sets when the <br>lifecycle policy should be evaluated. Max of 1 by UTC time | `string` | `"23:45"` | no |
| <a name="input_ca_ssh_public_keys"></a> [ca\_ssh\_public\_keys](#input\_ca\_ssh\_public\_keys) | List of SSH Certificate Authority public keys. Specifies a public <br>keys of certificate authorities that are trusted to sign <br>user certificates for authentication. More: <br>https://man.openbsd.org/sshd_config#TrustedUserCAKeys | `list(string)` | `[]` | no |
| <a name="input_ca_tls_public_keys"></a> [ca\_tls\_public\_keys](#input\_ca\_tls\_public\_keys) | List of custom Certificate Authority public keys. Used when need <br>to connect from Vault to resources with a self-signed certificate | `list(string)` | `[]` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of AWS certificate for assigning to ALB to determine TLS <br>connection. It should be a certificate issued for a domain that <br>will be assigned as CNAME record to ALB endpoint. If not set TLS <br>not be activated on ALB. More:<br>https://www.terraform.io/docs/providers/aws/r/\<br>acm\_certificate\_validation.html#certificate\_arn | `string` | `""` | no |
| <a name="input_cluster_allowed_subnets"></a> [cluster\_allowed\_subnets](#input\_cluster\_allowed\_subnets) | Allowed IPs to connect to a cluster on ALB endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_count"></a> [cluster\_count](#input\_cluster\_count) | Count of nodes in cluster across all availability zones | `number` | `3` | no |
| <a name="input_cluster_description"></a> [cluster\_description](#input\_cluster\_description) | Description for Tags in all resources.<br>Also used as a prefix for certificates "common\_name",<br>"organizational\_unit" and "organization" fields | `string` | `"Hashicorp Vault HA Cluster"` | no |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | Public cluster domain that will be assigned as CNAME record to<br>ALB endpoint. If not set ALB endpoint will be used | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of a cluster, and tag "Name", can be a project name.<br>Format of "Name" tag "<cluster\_prefix>-<cluster\_name>-<resource>" | `string` | `"vault-ha"` | no |
| <a name="input_cluster_port"></a> [cluster\_port](#input\_cluster\_port) | External port on ALB endpoint to a public connection | `number` | `443` | no |
| <a name="input_cluster_prefix"></a> [cluster\_prefix](#input\_cluster\_prefix) | Prefix of a tag "Name", can be a namespace.<br>Format of "Name" tag "<cluster\_prefix>-<cluster\_name>-<resource>" | `string` | `"tf-"` | no |
| <a name="input_data_volume_size"></a> [data\_volume\_size](#input\_data\_volume\_size) | Data (Raft) volume block device Size (GB) e.g. [8] | `number` | `8` | no |
| <a name="input_data_volume_type"></a> [data\_volume\_type](#input\_data\_volume\_type) | Data (Raft) volume block device Type e.g. [gp2] | `string` | `"gp2"` | no |
| <a name="input_debug"></a> [debug](#input\_debug) | Option for enabling debug output to plain files. When "true" <br>Terraform will store certificates, keys, ignitions files <br>(user data) JSON file to a folder "debug\_path" | `bool` | `false` | no |
| <a name="input_debug_path"></a> [debug\_path](#input\_debug\_path) | Path to folder where will be stored debug files.<br>If is empty then default "${path.module}/.debug"<br>you can set custom full path e.g. "/home/user/.debug" | `string` | `""` | no |
| <a name="input_disable_mlock"></a> [disable\_mlock](#input\_disable\_mlock) | Disables the server from executing the "mlock" syscall. Mlock <br>prevents memory from being swapped to disk. Disabling "mlock" is <br>not recommended in production, but is fine for local development <br>and testing | `bool` | `false` | no |
| <a name="input_docker_repo"></a> [docker\_repo](#input\_docker\_repo) | Vault Docker repository URI | `string` | `"vault"` | no |
| <a name="input_docker_tag"></a> [docker\_tag](#input\_docker\_tag) | Vault Docker image version tag | `string` | `"1.7.3"` | no |
| <a name="input_internal_zone"></a> [internal\_zone](#input\_internal\_zone) | Name for internal domain zone. Need for assigning domain names <br>to each of nodes for cluster server-to-server communication.<br>Also used for SSH connection over Bastion host. | `string` | `"vault.int"` | no |
| <a name="input_nat_enabled"></a> [nat\_enabled](#input\_nat\_enabled) | Determines to enable or disable creating NAT gateway and assigning <br>it to VPC Private Subnet. If you intend to use Vault only with <br>internal resources and internal network, you can disable this option <br>otherwise, you need to enable it. Allowing external routing might be <br>a potential security vulnerability. Also, enabling these options <br>will be additional money costs and not covered by the AWS Free Tier <br>program.<br>IMPORTANT: since during the creation of the cluster, the instance <br>needs to get a docker image, then it is necessary to enable <br>`nat_enabled` at the first initialization | `bool` | `false` | no |
| <a name="input_node_allow_public"></a> [node\_allow\_public](#input\_node\_allow\_public) | Assign public network to nodes (EC2 Instances). EC2 will be <br>available publicly with HTTPS "node\_port" ports and SSH "ssh\_port". <br>For debugging only, don't use on production! | `bool` | `false` | no |
| <a name="input_node_allowed_subnets"></a> [node\_allowed\_subnets](#input\_node\_allowed\_subnets) | If variable "node\_allow\_public" is set to "true" - list of these <br>IPs will be allowed to connect to Vault node directly (to instances) | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| <a name="input_node_cert_hours_valid"></a> [node\_cert\_hours\_valid](#input\_node\_cert\_hours\_valid) | The number of hours after initial issuing that the certificate <br>will become invalid for Vault node. The certificate used for <br>internal communication in a cluster by peers and to connect from <br>ALB. Not recommended set a small value as there is no reissuance <br>mechanism without applying of the Terraform | `number` | `43800` | no |
| <a name="input_node_cpu_credits"></a> [node\_cpu\_credits](#input\_node\_cpu\_credits) | The credit option for CPU usage [unlimited/standard] | `string` | `"standard"` | no |
| <a name="input_node_instance_type"></a> [node\_instance\_type](#input\_node\_instance\_type) | Type of instance e.g. [t3.small] | `string` | `"t3.small"` | no |
| <a name="input_node_monitoring"></a> [node\_monitoring](#input\_node\_monitoring) | CloudWatch detailed monitoring [true/false] | `bool` | `false` | no |
| <a name="input_node_name_tmpl"></a> [node\_name\_tmpl](#input\_node\_name\_tmpl) | Template of Vault node ID for a Raft cluster. Also used as a <br>subdomain prefix for internal domains for example: <br>"node0.vault.int", "node1.vault.int", etc | `string` | `"node%d"` | no |
| <a name="input_node_port"></a> [node\_port](#input\_node\_port) | Vault listens for ALB and health check requests | `number` | `8200` | no |
| <a name="input_node_volume_size"></a> [node\_volume\_size](#input\_node\_volume\_size) | Node (Root) volume block device Size (GB) e.g. [8] | `number` | `8` | no |
| <a name="input_node_volume_type"></a> [node\_volume\_type](#input\_node\_volume\_type) | Node (Root) volume block Device Type e.g. [gp2] | `string` | `"gp2"` | no |
| <a name="input_peer_port"></a> [peer\_port](#input\_peer\_port) | Vault listens for server-to-server cluster requests | `number` | `8201` | no |
| <a name="input_seal_awskms"></a> [seal\_awskms](#input\_seal\_awskms) | Map for an assignment for Vault to use AWS KMS as the seal <br>wrapping mechanism. If set will disable "seal\_transit". <br>More: https://www.vaultproject.io/docs/configuration/seal/awskms | `map(any)` | `{}` | no |
| <a name="input_seal_transit"></a> [seal\_transit](#input\_seal\_transit) | Map for assignment Transit seal configuration for use Vault's <br>Transit Secret Engine as the autoseal mechanism. <br>More: https://www.vaultproject.io/docs/configuration/seal/transit | `map(any)` | `{}` | no |
| <a name="input_ssh_admin_principals"></a> [ssh\_admin\_principals](#input\_ssh\_admin\_principals) | List of SSH authorized principals for user "Core" when SSH login <br>configured via Certificate Authority ("ca\_ssh\_public\_key" is set)<br>https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile | `list(string)` | <pre>[<br>  "vault-ha"<br>]</pre> | no |
| <a name="input_ssh_allowed_subnets"></a> [ssh\_allowed\_subnets](#input\_ssh\_allowed\_subnets) | If variable "node\_allow\_public" is set to "true" - list of these <br>IPs will be allowed to connect to Vault node by SSH directly (to <br>instances) | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | List of SSH authorized keys assigned to "Core" user (sudo user) | `list(string)` | `[]` | no |
| <a name="input_ssh_core_principals"></a> [ssh\_core\_principals](#input\_ssh\_core\_principals) | List of SSH authorized principals for user "Admin" when SSH login <br>configured via Certificate Authority ("ca\_ssh\_public\_key" is set) <br>More: https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile | `list(string)` | <pre>[<br>  "sudo"<br>]</pre> | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | Listening SSH port on instancies in public and private networks. <br>Changes used only when "ca\_ssh\_public\_key" set otherwise it equal <br>to 22 as default | `number` | `22` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags assigned to each or created resources in AWS. <br>By default, used predefined described map in a file "locals.tf".<br>Each of them can be overwritten here separately. | `map(string)` | `{}` | no |
| <a name="input_vault_ui"></a> [vault\_ui](#input\_vault\_ui) | Enables the built-in Vault web UI | `bool` | `true` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR associated with a module. Block sizes must be between a <br>/16 netmask and /28 netmask for AWS. For example: <br>`10.0.0.0/16-10.0.0.0/28`,<br>`172.16.0.0/16-172.16.0.0/28`,<br>`192.168.0.0/16-192.168.0.0/28` | `string` | `"192.168.0.0/16"` | no |
| <a name="input_vpc_id_external"></a> [vpc\_id\_external](#input\_vpc\_id\_external) | Provide existing external AWS VPC ID. If so configure corresponding <br>`vpc_public_subnet_cidr` and `vpc_private_subnet_cidr` to match <br>external VPC CIDR | `string` | `null` | no |
| <a name="input_vpc_private_subnet_cidr"></a> [vpc\_private\_subnet\_cidr](#input\_vpc\_private\_subnet\_cidr) | CIDR block for private subnet, must be canonical form, be in the same <br>network with VPC and non-overlapping with other subnets. For example:<br>subnet `/25`, (e.g. `172.31.31.0/25`) can contain up to 16 subnets <br>with a mask `/28` (subnet mask must be not less than `/28` for AWS) | `string` | `null` | no |
| <a name="input_vpc_private_subnet_mask"></a> [vpc\_private\_subnet\_mask](#input\_vpc\_private\_subnet\_mask) | Size of private subnet. The subnet mask must be not less than `/28` <br>for AWS. Mask /28 can contain up to 16 IP addresses but AWS reserved <br>5 addresses so 11 available for user. More: <br>https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html | `number` | `28` | no |
| <a name="input_vpc_private_subnet_tmpl"></a> [vpc\_private\_subnet\_tmpl](#input\_vpc\_private\_subnet\_tmpl) | VPC Private Subnet Template. Created for convenient use for a person <br>who is quite not enough familiar with networks and subnetworks. <br>Each index from the list of availability zones will be replaced <br>accordingly instead of the placeholder `%d`. Will be ignored if <br>variable `vpc_private_subnets` defined.<br>DEPRICETED: Try to avoid use this configuration, might be removed <br>in next versions. In this case, to avoid re-creations of cluster, <br>just describe your exists networks by `vpc_public_subnets` <br>parameters list for example: <br>["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24", ...] | `string` | `"192.168.10%d.0/24"` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | List of VPC Private Subnet. Each subnet will be assigned to <br>availability zone in order.<br>Mask must be not less than `/28` for AWS. Subnets should not overlap <br>and should be in the same network with `vpc_cidr` | `list(string)` | `[]` | no |
| <a name="input_vpc_public_subnet_cidr"></a> [vpc\_public\_subnet\_cidr](#input\_vpc\_public\_subnet\_cidr) | CIDR block for public subnet, must be canonical form, be in the same <br>network with VPC and non-overlapping with other subnets. For example:<br>subnet `/25`, (e.g. `172.31.31.0/25`) can contain up to 16 subnets <br>with a mask `/28` (subnet mask must be not less than `/28` for AWS) | `string` | `null` | no |
| <a name="input_vpc_public_subnet_mask"></a> [vpc\_public\_subnet\_mask](#input\_vpc\_public\_subnet\_mask) | Size of public subnet. The subnet mask must be not less than `/28` <br>for AWS. Mask /28 can contain up to 16 IP addresses but AWS reserved <br>5 addresses so 11 available for user. More: <br>https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html | `number` | `28` | no |
| <a name="input_vpc_public_subnet_tmpl"></a> [vpc\_public\_subnet\_tmpl](#input\_vpc\_public\_subnet\_tmpl) | VPC Public Subnet Template. Created for convenient use for a person <br>who is quite not enough familiar with networks and subnetworks. <br>Each index from the list of availability zones will be replaced <br>accordingly instead of the placeholder `%d`. Will be ignored if <br>variable `vpc_public_subnets` defined.<br>DEPRICETED: Try to avoid use this configuration, might be removed <br>in next versions. In this case, to avoid re-creations of cluster, <br>just describe your exists networks by `vpc_public_subnets` <br>parameters list for example: <br>["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", ...] | `string` | `"192.168.%d.0/24"` | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | List of VPC Public Subnets. Each subnet will be assigned to <br>availability zone in order.<br>Mask must be not less than `/28` for AWS. Subnets should not overlap <br>and should be in the same network with `vpc_cidr` | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | ALB external endpoint DNS name. Should use to assign <br>"CNAME" record of public domain |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | ALB canonical hosted Zone ID of the load balancer.<br>Should use to assign Route 53 "Alias" record (AWS only). |
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
| <a name="output_igw_public_ips"></a> [igw\_public\_ips](#output\_igw\_public\_ips) | List of Internet public IPs. If cluster nodes are determined to be <br>in the public subnet (Internet Gateway used) all external network <br>requests will be via public IPs assigned to the nodes. This list <br>can be used for configuring security groups of related services or <br>connect to the nodes via SSH on debugging |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | NAT public IPs assigned as an external IP for requests from <br>each of the nodes. Convenient to use for restrict application, <br>audit logs, some security groups, or other IP-based security <br>policies. Note: if set "node\_allow\_public" each node will get <br>its own public IP which will be used for external requests.<br>If `var.nat_enabled` set to `false` returns an empty list. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of Private Subnet IDs created in a module and associated with it. <br>Under the hood is using "NAT Gateway" to external connections for the <br>"Route 0.0.0.0/0". When variable "node\_allow\_public" = false, this <br>network assigned to the instancies. For other cases, this useful to <br>assign another resource in this VPS for example Database which can <br>work behind a NAT (or without NAT at all and external connections <br>for security reasons) and not needs to be exposed publicly by own IP. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of Public Subnet IDs created in a module and associated with it. <br>Under the hood is using "Internet Gateway" to external connections <br>for the "Route 0.0.0.0/0". When variable "node\_allow\_public" = true, <br>this network assigned to the instancies. For other cases this useful <br>to assign another resource in this VPS for example Bastion host which <br>need to be exposed publicly by own IP and not behind a NAT. |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | Route Table ID assigned to the current Vault HA cluster subnet. <br>Depends on which subnetwork assigned to instances Private or Public. |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | SSH private key which generated by module and its public key <br>part assigned to each of nodes. Don't recommended do this as <br>a private key will be kept open and stored in a state file. <br>Instead of this set variable "ssh\_authorized\_keys". Please note, <br>if "ssh\_authorized\_keys" set "ssh\_private\_key" return empty output |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID created in a module and associated with it. Need to be exposed <br>for assigning other resources to the same VPC or for configuration a <br>peering connections. If configured `vpc_id_external` will return it |
| <a name="output_vpc_security_group"></a> [vpc\_security\_group](#output\_vpc\_security\_group) | VPC Security Group ID which allow connecting to "cluster\_port", <br>"node\_port" and "ssh\_port". Useful for debugging when Bastion host <br>connected to the same VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
