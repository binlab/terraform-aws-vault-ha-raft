# AWS IAM Granular Permissions

*Here described all IAM granular permissions for creating a cluster in AWS. The list might be not complete and contain mistakes. Due to the complex permissions system in AWS IAM is difficult to describe all need Actions. In addition, there are no tools in the Terraform to analyze needed permission. If you don't need a strict list of permissions please use a wildcard option e.g. `ec2:*` Otherwise, use this **AS-IS** and you can open an issue for missed permissions. Thanks.*

### EC2 - Provisioning instances

```json
{
  "Sid": "EC2ProvisioningInstances",
  "Effect": "Allow",
  "Action": [
    "ec2:AllocateAddress",
    "ec2:AssociateRouteTable",
    "ec2:AttachInternetGateway",
    "ec2:AttachVolume",
    "ec2:AuthorizeSecurityGroupEgress",
    "ec2:AuthorizeSecurityGroupIngress",
    "ec2:CreateInternetGateway",
    "ec2:CreateNatGateway",
    "ec2:CreateRoute",
    "ec2:CreateRouteTable",
    "ec2:CreateSecurityGroup",
    "ec2:CreateSubnet",
    "ec2:CreateTags",
    "ec2:CreateVolume",
    "ec2:CreateVpc",
    "ec2:DeleteInternetGateway",
    "ec2:DeleteNatGateway",
    "ec2:DeleteRoute",
    "ec2:DeleteRouteTable",
    "ec2:DeleteSecurityGroup",
    "ec2:DeleteSubnet",
    "ec2:DeleteVolume",
    "ec2:DeleteVpc",
    "ec2:DescribeAccountAttributes",
    "ec2:DescribeAddresses",
    "ec2:DescribeAvailabilityZones",
    "ec2:DescribeImages",
    "ec2:DescribeInstanceAttribute",
    "ec2:DescribeInstanceCreditSpecifications",
    "ec2:DescribeInstances",
    "ec2:DescribeInternetGateways",
    "ec2:DescribeNatGateways",
    "ec2:DescribeNetworkAcls",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DescribeRouteTables",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeSubnets",
    "ec2:DescribeTags",
    "ec2:DescribeVolumes",
    "ec2:DescribeVpcAttribute",
    "ec2:DescribeVpcClassicLink",
    "ec2:DescribeVpcClassicLinkDnsSupport",
    "ec2:DescribeVpcs",
    "ec2:DetachInternetGateway",
    "ec2:DetachNetworkInterface",
    "ec2:DetachVolume",
    "ec2:DisassociateRouteTable",
    "ec2:ModifyInstanceAttribute",
    "ec2:ModifySubnetAttribute",
    "ec2:ModifyVpcAttribute",
    "ec2:MonitorInstances",
    "ec2:ReleaseAddress",
    "ec2:RevokeSecurityGroupEgress",
    "ec2:RunInstances",
    "ec2:StartInstances",
    "ec2:StopInstances",
    "ec2:TerminateInstances",
    "ec2:UnmonitorInstances"
  ],
  "Resource": "*"
}
```

### DLM - Creating auto-snapshots by AWS

```json
{
  "Sid": "DLMAutoSnapshots",
  "Effect": "Allow",
  "Action": [
    "DLM:CreateLifecyclePolicy",
    "DLM:DeleteLifecyclePolicy",
    "DLM:GetLifecyclePolicy",
    "DLM:TagResource",
    "DLM:UpdateLifecyclePolicy"
  ],
  "Resource": "*"
}
```

### ALB - Provisioning Load Balancer

```json
{
  "Sid": "ALBProvisioningLoadBalancer",
  "Effect": "Allow",
  "Action": [
    "elasticloadbalancing:AddTags",
    "elasticloadbalancing:CreateListener",
    "elasticloadbalancing:CreateLoadBalancer",
    "elasticloadbalancing:CreateTargetGroup",
    "elasticloadbalancing:DeleteListener",
    "elasticloadbalancing:DeleteLoadBalancer",
    "elasticloadbalancing:DeleteTargetGroup",
    "elasticloadbalancing:DeregisterTargets",
    "elasticloadbalancing:DescribeListeners",
    "elasticloadbalancing:DescribeLoadBalancerAttributes",
    "elasticloadbalancing:DescribeLoadBalancers",
    "elasticloadbalancing:DescribeTags",
    "elasticloadbalancing:DescribeTargetGroupAttributes",
    "elasticloadbalancing:DescribeTargetGroups",
    "elasticloadbalancing:DescribeTargetHealth",
    "elasticloadbalancing:ModifyLoadBalancerAttributes",
    "elasticloadbalancing:ModifyTargetGroup",
    "elasticloadbalancing:ModifyTargetGroupAttributes",
    "elasticloadbalancing:RegisterTargets",
    "elasticloadbalancing:SetSecurityGroups"
  ],
  "Resource": "*"
}
```

### IAM - Permissions for KMS and DLM

```json
{
  "Sid": "IAMPermissionsKMSAndDLM",
  "Effect": "Allow",
  "Action": [
    "iam:AddRoleToInstanceProfile",
    "iam:CreateInstanceProfile",
    "iam:CreateRole",
    "iam:DeleteInstanceProfile",
    "iam:DeleteRole",
    "iam:DeleteRolePolicy",
    "iam:GetInstanceProfile",
    "iam:GetRole",
    "iam:GetRolePolicy",
    "iam:ListInstanceProfilesForRole",
    "iam:PutRolePolicy",
    "iam:RemoveRoleFromInstanceProfile"
  ],
  "Resource": "*"
}
```

### KMS - Provisioning Auto-Unseal

```json
{
  "Sid": "KMSProvisioningAutoUnseal",
  "Effect": "Allow",
  "Action": [
    "kms:CreateKey",
    "kms:DescribeKey",
    "kms:GetKeyPolicy",
    "kms:GetKeyRotationStatus",
    "kms:ListResourceTags",
    "kms:ScheduleKeyDeletion",
    "kms:TagResource",
    "kms:UpdateKeyDescription"
  ],
  "Resource": "*"
}
```

### Route53 - Provisioning Internal Zone

```json
{
  "Sid": "Route53ProvisioningInternalZone",
  "Effect": "Allow",
  "Action": [
    "route53:ChangeResourceRecordSets",
    "route53:ChangeTagsForResource",
    "route53:CreateHostedZone",
    "route53:DeleteHostedZone",
    "route53:GetChange",
    "route53:GetHostedZone",
    "route53:ListResourceRecordSets",
    "route53:ListTagsForResource"
  ],
  "Resource": "*"
}
```

### STS - Provide Metadata

```json
{
  "Sid": "STSProvideMetadata",
  "Effect": "Allow",
  "Action": [
    "sts:GetCallerIdentity"
  ],
  "Resource": "*"
}
```