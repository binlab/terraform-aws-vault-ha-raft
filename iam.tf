data "aws_iam_policy_document" "autounseal_sts" {
  count = var.autounseal ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "autounseal" {
  count = var.autounseal ? 1 : 0

  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = [local.kms_key_arn]
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_role" "autounseal" {
  count = var.autounseal ? 1 : 0

  name               = format(local.name_tmpl, "autounseal")
  assume_role_policy = data.aws_iam_policy_document.autounseal_sts[0].json
}

resource "aws_iam_role_policy" "autounseal" {
  count = var.autounseal ? 1 : 0

  name   = format(local.name_tmpl, "autounseal")
  role   = aws_iam_role.autounseal[0].id
  policy = data.aws_iam_policy_document.autounseal[0].json
}

resource "aws_iam_instance_profile" "autounseal" {
  count = var.autounseal ? 1 : 0

  name = format(local.name_tmpl, "autounseal")
  role = aws_iam_role.autounseal[0].name
}
