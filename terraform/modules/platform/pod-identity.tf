data "aws_iam_policy_document" "external_dns" {
  statement {
    sid = "ChangeRecordsInOurZone"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [var.zone_arn]
  }

  statement {
    sid = "DiscoverZones"
    actions = [
      "route53:ListHostedZones",
      "route53:ListTagsForResources",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [var.zone_arn]
  }

  statement {
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

module "cert_manager_pod_identity" {
  source = "../pod-id-role"

  role_name       = "${var.cluster_name}-cert-manager"
  cluster_name    = var.cluster_name
  namespace       = "cert-manager"
  service_account = "cert-manager"
  policy_json     = data.aws_iam_policy_document.cert_manager.json
}

module "external_dns_pod_identity" {
  source = "../pod-id-role"

  role_name       = "${var.cluster_name}-external-dns"
  cluster_name    = var.cluster_name
  namespace       = "external-dns"
  service_account = "external-dns"
  policy_json     = data.aws_iam_policy_document.external_dns.json
}