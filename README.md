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
- Fast and easily manual creating snapshots (*backups*) from [Vault UI](docs/raft-manual-shapshots.md) (thanks **Raft** [implementations](https://www.vaultproject.io/docs/commands/operator/raft))
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

The module can be deployed with almost default values of variables. For more details of the default values looking [here](#inputs)

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vault_ha" {
  source = "github.com/binlab/terraform-aws-vault-ha-raft?ref=v0.1.0"

  cluster_name        = "vault-ha"
  node_instance_type  = "t3a.small"
  autounseal          = true
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

*Then just open URL in a browser and initialize the cluster*

## TODO

- [ ] Add examples of use with different cases [#10](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/10)
- [ ] Hosted module on [Terraform Registry](https://registry.terraform.io) [#13](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/13)
- [ ] Add validation of input data in [variables.tf](variables.tf) 
- [ ] Add support **Fedora CoreOS** as [announced](https://coreos.com/os/docs/latest/cloud-config-deprecated.html) **CoreOS Container Linux** will reach its end of life on **May 26, 2020** and will no longer receive updates.
- [ ] Remove external dependency - *VPC Module* - [#7](https://github.com/binlab/terraform-aws-vault-ha-raft/issues/7)
- [ ] Add configuration for an external Vault Audit Device via [syslog](https://www.vaultproject.io/docs/audit/syslog) or [socket](https://www.vaultproject.io/docs/audit/socket)
- [ ] *Third-party plugins* installation support
- [ ] Add optional opened `HTTP` port on **ALB** and setup redirect from `HTTP` to `HTTPS`. Canonical support 
- [ ] Disable **NAT Gateway** by default (*for reducing costs consumptions*)
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


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.53.0 |
| ignition | >= 1.2.1 |
| local | >= 1.4.0 |
| tls | >= 2.1.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.53.0 |
| ignition | >= 1.2.1 |
| local | >= 1.4.0 |
| tls | >= 2.1.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_channel | AMI filter for OS channel [stable/edge/beta/etc] | `string` | `"stable"` | no |
| ami\_image | Specific AMI image ID in current Avalability Zone e.g. [ami-123456]<br>If provided nodes will be run on it, for cases when image built by <br>Packer if set it will disable search images by "ami\_vendor" and <br>"ami\_channel". Note: Instance OS should support CoreOS Ignition <br>provisioning | `string` | `""` | no |
| ami\_vendor | AMI filter for OS vendor [coreos/flatcar] | `string` | `"flatcar"` | no |
| autounseal | Option to enable/disable creating KMS key, IAM role, policy and <br>AssumeRole for autounseal by AWS. Instead of creating by module, <br>can be used external resources for autounseal or without it at all. <br>If set will disable "seal\_transit" and "seal\_awskms". | `bool` | `false` | no |
| aws\_snapshots | Option to enable/disable embedded snapshots by AWS | `bool` | `false` | no |
| aws\_snapshots\_interval | Snapshot Interval. How often this lifecycle policy <br>should be evaluated. 2,3,4,6,8,12 or 24 are valid values | `number` | `24` | no |
| aws\_snapshots\_retain | How many snapshots to keep. Must be an integer between 1 and 1000 | `number` | `7` | no |
| aws\_snapshots\_time | A list of times in 24 hour clock format that sets when the <br>lifecycle policy should be evaluated. Max of 1 by UTC time | `string` | `"23:45"` | no |
| ca\_ssh\_public\_keys | List of SSH Certificate Authority public keys. Specifies a public <br>keys of certificate authorities that are trusted to sign <br>user certificates for authentication. More: <br>https://man.openbsd.org/sshd_config#TrustedUserCAKeys | `list(string)` | `[]` | no |
| ca\_tls\_public\_keys | List of custom Certificate Authority public keys. Used when need <br>to connect from Vault to resources with a self-signed certificate | `list(string)` | `[]` | no |
| certificate\_arn | ARN of AWS certificate for assigning to ALB to determine TLS <br>connection. It should be a certificate issued for a domain that <br>will be assigned as CNAME record to ALB endpoint. If not set TLS <br>not be activated on ALB. More:<br>https://www.terraform.io/docs/providers/aws/r/\<br>acm\_certificate\_validation.html#certificate\_arn | `string` | `""` | no |
| cluster\_allowed\_subnets | Allowed IPs to connect to a cluster on ALB endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| cluster\_count | Count of nodes in cluster across all availability zones | `number` | `3` | no |
| cluster\_description | Description for Tags in all resources.<br>Also used as a prefix for certificates "common\_name",<br>"organizational\_unit" and "organization" fields | `string` | `"Hashicorp Vault HA Cluster"` | no |
| cluster\_domain | Public cluster domain that will be assigned as CNAME record to <br>ALB endpoint. If not set ALB endpoint will be used | `string` | `""` | no |
| cluster\_name | Name of a cluster, and tag "Name", can be a project name.<br>Format of "Name" tag "<cluster\_prefix>-<cluster\_name>-<resource>" | `string` | `"vault-ha"` | no |
| cluster\_port | External port on ALB endpoint to a public connection | `number` | `443` | no |
| cluster\_prefix | Prefix of a tag "Name", can be a namespace.<br>Format of "Name" tag "<cluster\_prefix>-<cluster\_name>-<resource>" | `string` | `"tf-"` | no |
| data\_volume\_size | Data (Raft) volume block device Size (GB) e.g. [8] | `number` | `8` | no |
| data\_volume\_type | Data (Raft) volume block device Type e.g. [gp2] | `string` | `"gp2"` | no |
| debug | Option for enabling debug output to plain files. When "true" <br>Terraform will store certificates, keys, ignitions files <br>(user data) JSON file to a folder "debug\_path" | `bool` | `false` | no |
| debug\_path | Path to folder where will be stored debug files.<br>If is empty then default "${path.module}/.debug"<br>you can set custom full path e.g. "/home/user/.debug" | `string` | `""` | no |
| disable\_mlock | Disables the server from executing the "mlock" syscall. Mlock <br>prevents memory from being swapped to disk. Disabling "mlock" is <br>not recommended in production, but is fine for local development <br>and testing | `bool` | `false` | no |
| docker\_repo | Vault Docker repository URI | `string` | `"docker://vault"` | no |
| docker\_tag | Vault Docker image version tag | `string` | `"1.4.2"` | no |
| internal\_zone | Name for internal domain zone. Need for assigning domain names <br>to each of nodes for cluster server-to-server communication.<br>Also used for SSH connection over Bastion host. | `string` | `"vault.int"` | no |
| node\_allow\_public | Assign public network to nodes (EC2 Instances). EC2 will be <br>available publicly with HTTPS "node\_port" ports and SSH "ssh\_port". <br>For debugging only, don't use on production! | `bool` | `false` | no |
| node\_allowed\_subnets | If variable "node\_allow\_public" is set to "true" - list of these <br>IPs will be allowed to connect to Vault node directly (to instances) | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| node\_cert\_hours\_valid | The number of hours after initial issuing that the certificate <br>will become invalid for Vault node. The certificate used for <br>internal communication in a cluster by peers and to connect from <br>ALB. Not recommended set a small value as there is no reissuance <br>mechanism without applying of the Terraform | `number` | `43800` | no |
| node\_cpu\_credits | The credit option for CPU usage [unlimited/standard] | `string` | `"standard"` | no |
| node\_instance\_type | Type of instance e.g. [t3.small] | `string` | `"t3.small"` | no |
| node\_monitoring | CloudWatch detailed monitoring [true/false] | `bool` | `false` | no |
| node\_name\_tmpl | Template of Vault node ID for a Raft cluster. Also used as a <br>subdomain prefix for internal domains for example: <br>"node0.vault.int", "node1.vault.int", etc | `string` | `"node%d"` | no |
| node\_port | Vault listens for ALB and health check requests | `number` | `8200` | no |
| node\_volume\_size | Node (Root) volume block device Size (GB) e.g. [8] | `number` | `8` | no |
| node\_volume\_type | Node (Root) volume block Device Type e.g. [gp2] | `string` | `"gp2"` | no |
| peer\_port | Vault listens for server-to-server cluster requests | `number` | `8201` | no |
| seal\_awskms | Map for an assignment for Vault to use AWS KMS as the seal <br>wrapping mechanism. If set will disable "seal\_transit". <br>More: https://www.vaultproject.io/docs/configuration/seal/awskms | `map` | `{}` | no |
| seal\_transit | Map for assignment Transit seal configuration for use Vault's <br>Transit Secret Engine as the autoseal mechanism. <br>More: https://www.vaultproject.io/docs/configuration/seal/transit | `map` | `{}` | no |
| ssh\_admin\_principals | List of SSH authorized principals for user "Core" when SSH login <br>configured via Certificate Authority ("ca\_ssh\_public\_key" is set)<br>https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile | `list(string)` | <pre>[<br>  "vault-ha"<br>]</pre> | no |
| ssh\_allowed\_subnets | If variable "node\_allow\_public" is set to "true" - list of these <br>IPs will be allowed to connect to Vault node by SSH directly (to <br>instances) | `list(string)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| ssh\_authorized\_keys | List of SSH authorized keys assigned to "Core" user (sudo user) | `list(string)` | `[]` | no |
| ssh\_core\_principals | List of SSH authorized principals for user "Admin" when SSH login <br>configured via Certificate Authority ("ca\_ssh\_public\_key" is set) <br>More: https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile | `list(string)` | <pre>[<br>  "sudo"<br>]</pre> | no |
| ssh\_port | Listening SSH port on instancies in public and private networks. <br>Changes used only when "ca\_ssh\_public\_key" set otherwise it equal <br>to 22 as default | `number` | `22` | no |
| tags | Map of tags assigned to each or created resources in AWS. <br>By default, used predefined described map in a file "locals.tf".<br>Each of them can be overwritten here separately. | `map(string)` | `{}` | no |
| vault\_ui | Enables the built-in Vault web UI | `bool` | `true` | no |
| vpc\_cidr | VPC CIDR associated with a module | `string` | `"192.168.0.0/16"` | no |
| vpc\_private\_subnet\_tmpl | VPC Private Subnet Template | `string` | `"192.168.10%d.0/24"` | no |
| vpc\_public\_subnet\_tmpl | VPC Public Subnet Template | `string` | `"192.168.%d.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_dns\_name | ALB external endpoint DNS name. Should use to assign <br>"CNAME" record of public domain |
| alb\_zone\_id | ALB canonical hosted Zone ID of the load balancer.<br>Should use to assign Route 53 "Alias" record (AWS only). |
| cluster\_url | Cluster public URL with schema, domain, and port.<br>All parameters depend on inputs values and calculated automatically <br>for convenient use. Can be created separately outside a module |
| nat\_public\_ips | NAT public IPs assigned as an external IP for requests from <br>each of the nodes. Convenient to use for restrict application, <br>audit logs, some security groups, or other IP-based security <br>policies. Note: if set "node\_allow\_public" each node will get <br>its own public IP which will be used for external requests |
| private\_subnets | List of Private Subnet IDs created in a module and associated with it. <br>Under the hood is using "NAT Gateway" to external connections for the <br>"Route 0.0.0.0/0". When variable "node\_allow\_public" = false, this <br>network assigned to the instancies. For other cases, this useful to <br>assign another resource in this VPS for example Database which can <br>work behind a NAT (or without NAT at all and external connections <br>for security reasons) and not needs to be exposed publicly by own IP. |
| public\_subnets | List of Public Subnet IDs created in a module and associated with it. <br>Under the hood is using "Internet Gateway" to external connections <br>for the "Route 0.0.0.0/0". When variable "node\_allow\_public" = true, <br>this network assigned to the instancies. For other cases this useful <br>to assign another resource in this VPS for example Bastion host which <br>need to be exposed publicly by own IP and not behind a NAT. |
| route\_table | Route Table ID assigned to the current Vault HA cluster subnet. <br>Depends on which subnetwork assigned to instances Private or Public. |
| ssh\_private\_key | SSH private key which generated by module and its public key <br>part assigned to each of nodes. Don't recommended do this as <br>a private key will be kept open and stored in a state file. <br>Instead of this set variable "ssh\_authorized\_keys". Please note, <br>if "ssh\_authorized\_keys" set "ssh\_private\_key" return empty output |
| vpc\_id | VPC ID created in a module and associated with it. Need to be exposed <br>for assigning other resources to the same VPC or for configuration a <br>peering connections |
| vpc\_security\_group | VPC Security Group ID which allow connecting to "cluster\_port", <br>"node\_port" and "ssh\_port". Useful for debugging when Bastion host <br>connected to the same VPC |
