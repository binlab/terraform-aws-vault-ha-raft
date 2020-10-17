variable "cluster_name" {
  description = <<-EOT
    Name of a cluster, and tag "Name", can be a project name.
    Format of "Name" tag "<cluster_prefix>-<cluster_name>-<resource>"
  EOT
  type        = string
  default     = "vault-ha"
}

variable "cluster_prefix" {
  description = <<-EOT
    Prefix of a tag "Name", can be a namespace.
    Format of "Name" tag "<cluster_prefix>-<cluster_name>-<resource>"
  EOT
  type        = string
  default     = "tf-"
}

variable "cluster_description" {
  description = <<-EOT
    Description for Tags in all resources.
    Also used as a prefix for certificates "common_name",
    "organizational_unit" and "organization" fields
  EOT
  type        = string
  default     = "Hashicorp Vault HA Cluster"
}

variable "cluster_count" {
  description = <<-EOT
    Count of nodes in cluster across all availability zones
  EOT
  type        = number
  default     = 3
}

variable "cluster_domain" {
  description = <<-EOT
    Public cluster domain that will be assigned as CNAME record to
    ALB endpoint. If not set ALB endpoint will be used
  EOT
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = <<-EOT
    VPC CIDR associated with a module. Block sizes must be between a 
    /16 netmask and /28 netmask for AWS. For example: 
    `10.0.0.0/16-10.0.0.0/28`,
    `172.16.0.0/16-172.16.0.0/28`,
    `192.168.0.0/16-192.168.0.0/28`
  EOT
  type        = string
  default     = "192.168.0.0/16"
}

variable "vpc_public_subnets" {
  description = <<-EOT
    List of VPC Public Subnets. Each subnet will be assigned to 
    availability zone in order.
    Mask must be not less than `/28` for AWS. Subnets should not overlap 
    and should be in the same network with `vpc_cidr`
  EOT
  type        = list(string)
  default     = []
}

variable "vpc_private_subnets" {
  description = <<-EOT
    List of VPC Private Subnet. Each subnet will be assigned to 
    availability zone in order.
    Mask must be not less than `/28` for AWS. Subnets should not overlap 
    and should be in the same network with `vpc_cidr`
  EOT
  type        = list(string)
  default     = []
}

variable "vpc_public_subnet_tmpl" {
  description = <<-EOT
    VPC Public Subnet Template. Created for convenient use for a person 
    who is quite not enough familiar with networks and subnetworks. 
    Each index from the list of availability zones will be replaced 
    accordingly instead of the placeholder `%d`. Will be ignored if 
    variable `vpc_public_subnets` defined.
  EOT
  type        = string
  default     = "192.168.%d.0/24"
}

variable "vpc_private_subnet_tmpl" {
  description = <<-EOT
    VPC Private Subnet Template. Created for convenient use for a person 
    who is quite not enough familiar with networks and subnetworks. 
    Each index from the list of availability zones will be replaced 
    accordingly instead of the placeholder `%d`. Will be ignored if 
    variable `vpc_private_subnet` defined.
  EOT
  type        = string
  default     = "192.168.10%d.0/24"
}

variable "nat_enabled" {
  description = <<-EOT
    Determines to enable or disable creating NAT gateway and assigning 
    it to VPC Private Subnet. If you intend to use Vault only with 
    internal resources and internal network, you can disable this option 
    otherwise, you need to enable it. Allowing external routing might be 
    a potential security vulnerability. Also, enabling these options 
    will be additional money costs and not covered by the AWS Free Tier 
    program.
  EOT
  type        = bool
  default     = false
}

variable "cluster_port" {
  description = <<-EOT
    External port on ALB endpoint to a public connection
  EOT
  type        = number
  default     = 443
}

variable "cluster_allowed_subnets" {
  description = <<-EOT
    Allowed IPs to connect to a cluster on ALB endpoint
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_port" {
  description = <<-EOT
    Vault listens for ALB and health check requests
  EOT
  type        = number
  default     = 8200
}

variable "node_allowed_subnets" {
  description = <<-EOT
    If variable "node_allow_public" is set to "true" - list of these 
    IPs will be allowed to connect to Vault node directly (to instances)
  EOT
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "ssh_port" {
  description = <<-EOT
    Listening SSH port on instancies in public and private networks. 
    Changes used only when "ca_ssh_public_key" set otherwise it equal 
    to 22 as default
  EOT
  type        = number
  default     = 22
}

variable "ssh_allowed_subnets" {
  description = <<-EOT
    If variable "node_allow_public" is set to "true" - list of these 
    IPs will be allowed to connect to Vault node by SSH directly (to 
    instances)
  EOT
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "peer_port" {
  description = <<-EOT
    Vault listens for server-to-server cluster requests
  EOT
  type        = number
  default     = 8201
}

variable "node_allow_public" {
  description = <<-EOT
    Assign public network to nodes (EC2 Instances). EC2 will be 
    available publicly with HTTPS "node_port" ports and SSH "ssh_port". 
    For debugging only, don't use on production!
  EOT
  type        = bool
  default     = false
}

variable "ami_vendor" {
  description = <<-EOT
    AMI filter for OS vendor [coreos/flatcar]
  EOT
  type        = string
  default     = "flatcar"
}

variable "ami_channel" {
  description = <<-EOT
    AMI filter for OS channel [stable/edge/beta/etc]
  EOT
  type        = string
  default     = "stable"
}

variable "ami_image" {
  description = <<-EOT
    Specific AMI image ID in current Avalability Zone e.g. [ami-123456]
    If provided nodes will be run on it, for cases when image built by 
    Packer if set it will disable search images by "ami_vendor" and 
    "ami_channel". Note: Instance OS should support CoreOS Ignition 
    provisioning
  EOT
  type        = string
  default     = ""
}

variable "node_instance_type" {
  description = <<-EOT
    Type of instance e.g. [t3.small]
  EOT
  type        = string
  default     = "t3.small"
}

variable "node_monitoring" {
  description = <<-EOT
    CloudWatch detailed monitoring [true/false]
  EOT
  type        = bool
  default     = false
}

variable "node_volume_size" {
  description = <<-EOT
    Node (Root) volume block device Size (GB) e.g. [8]
  EOT
  type        = number
  default     = 8
}

variable "node_volume_type" {
  description = <<-EOT
    Node (Root) volume block Device Type e.g. [gp2]
  EOT
  type        = string
  default     = "gp2"
}

variable "data_volume_size" {
  description = <<-EOT
    Data (Raft) volume block device Size (GB) e.g. [8]
  EOT
  type        = number
  default     = 8
}

variable "data_volume_type" {
  description = <<-EOT
    Data (Raft) volume block device Type e.g. [gp2]
  EOT
  type        = string
  default     = "gp2"
}

variable "node_cpu_credits" {
  description = <<-EOT
    The credit option for CPU usage [unlimited/standard]
  EOT
  type        = string
  default     = "standard"
}

variable "ssh_authorized_keys" {
  description = <<-EOT
    List of SSH authorized keys assigned to "Core" user (sudo user)
  EOT
  type        = list(string)
  default     = []
}

variable "ca_ssh_public_keys" {
  description = <<-EOT
    List of SSH Certificate Authority public keys. Specifies a public 
    keys of certificate authorities that are trusted to sign 
    user certificates for authentication. More: 
    https://man.openbsd.org/sshd_config#TrustedUserCAKeys
  EOT
  type        = list(string)
  default     = []
}

variable "ssh_core_principals" {
  description = <<-EOT
    List of SSH authorized principals for user "Admin" when SSH login 
    configured via Certificate Authority ("ca_ssh_public_key" is set) 
    More: https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile
  EOT
  type        = list(string)
  default     = ["sudo"]
}

variable "ssh_admin_principals" {
  description = <<-EOT
    List of SSH authorized principals for user "Core" when SSH login 
    configured via Certificate Authority ("ca_ssh_public_key" is set)
    https://man.openbsd.org/sshd_config#AuthorizedPrincipalsFile
  EOT
  type        = list(string)
  default     = ["vault-ha"]
}

variable "ca_tls_public_keys" {
  description = <<-EOT
    List of custom Certificate Authority public keys. Used when need 
    to connect from Vault to resources with a self-signed certificate
  EOT
  type        = list(string)
  default     = []
}

variable "node_cert_hours_valid" {
  description = <<-EOT
    The number of hours after initial issuing that the certificate 
    will become invalid for Vault node. The certificate used for 
    internal communication in a cluster by peers and to connect from 
    ALB. Not recommended set a small value as there is no reissuance 
    mechanism without applying of the Terraform
  EOT
  type        = number
  default     = 43800
}

variable "certificate_arn" {
  description = <<-EOT
    ARN of AWS certificate for assigning to ALB to determine TLS 
    connection. It should be a certificate issued for a domain that 
    will be assigned as CNAME record to ALB endpoint. If not set TLS 
    not be activated on ALB. More:
    https://www.terraform.io/docs/providers/aws/r/\
    acm_certificate_validation.html#certificate_arn
  EOT
  type        = string
  default     = ""
}

variable "autounseal" {
  description = <<-EOT
    Option to enable/disable creating KMS key, IAM role, policy and 
    AssumeRole for autounseal by AWS. Instead of creating by module, 
    can be used external resources for autounseal or without it at all. 
    If set will disable "seal_transit" and "seal_awskms".
  EOT
  type        = bool
  default     = false
}

variable "seal_awskms" {
  description = <<-EOT
    Map for an assignment for Vault to use AWS KMS as the seal 
    wrapping mechanism. If set will disable "seal_transit". 
    More: https://www.vaultproject.io/docs/configuration/seal/awskms
  EOT
  type        = map
  default     = {}
}

variable "seal_transit" {
  description = <<-EOT
    Map for assignment Transit seal configuration for use Vault's 
    Transit Secret Engine as the autoseal mechanism. 
    More: https://www.vaultproject.io/docs/configuration/seal/transit
  EOT
  type        = map
  default     = {}
}

variable "tags" {
  description = <<-EOT
    Map of tags assigned to each or created resources in AWS. 
    By default, used predefined described map in a file "locals.tf".
    Each of them can be overwritten here separately.
  EOT
  type        = map(string)
  default     = {}
}

variable "internal_zone" {
  description = <<-EOT
    Name for internal domain zone. Need for assigning domain names 
    to each of nodes for cluster server-to-server communication.
    Also used for SSH connection over Bastion host.
  EOT
  type        = string
  default     = "vault.int"
}

variable "node_name_tmpl" {
  description = <<-EOT
    Template of Vault node ID for a Raft cluster. Also used as a 
    subdomain prefix for internal domains for example: 
    "node0.vault.int", "node1.vault.int", etc
  EOT
  type        = string
  default     = "node%d"
}

variable "docker_repo" {
  description = <<-EOT
    Vault Docker repository URI
  EOT
  type        = string
  default     = "docker://vault"
}

variable "docker_tag" {
  description = <<-EOT
    Vault Docker image version tag
  EOT
  type        = string
  default     = "1.4.2"
}

variable "disable_mlock" {
  description = <<-EOT
    Disables the server from executing the "mlock" syscall. Mlock 
    prevents memory from being swapped to disk. Disabling "mlock" is 
    not recommended in production, but is fine for local development 
    and testing
  EOT
  type        = bool
  default     = false
}

variable "vault_ui" {
  description = <<-EOT
    Enables the built-in Vault web UI
  EOT
  type        = bool
  default     = true
}

variable "aws_snapshots" {
  description = <<-EOT
    Option to enable/disable embedded snapshots by AWS
  EOT
  type        = bool
  default     = false
}

variable "aws_snapshots_interval" {
  description = <<-EOT
    Snapshot Interval. How often this lifecycle policy 
    should be evaluated. 2,3,4,6,8,12 or 24 are valid values
  EOT
  type        = number
  default     = 24
}

variable "aws_snapshots_time" {
  description = <<-EOT
    A list of times in 24 hour clock format that sets when the 
    lifecycle policy should be evaluated. Max of 1 by UTC time
  EOT
  type        = string
  default     = "23:45"
}

variable "aws_snapshots_retain" {
  description = <<-EOT
    How many snapshots to keep. Must be an integer between 1 and 1000
  EOT
  type        = number
  default     = 7
}

variable "debug" {
  description = <<-EOT
    Option for enabling debug output to plain files. When "true" 
    Terraform will store certificates, keys, ignitions files 
    (user data) JSON file to a folder "debug_path"
  EOT
  type        = bool
  default     = false
}

variable "debug_path" {
  description = <<-EOT
    Path to folder where will be stored debug files.
    If is empty then default "$${path.module}/.debug"
    you can set custom full path e.g. "/home/user/.debug"
  EOT
  type        = string
  default     = ""
}
