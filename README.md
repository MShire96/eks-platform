# EKS Platform

A production-style Kubernetes platform on AWS EKS, built with Terraform and developed locally against [MiniStack](https://ministack.org/) to keep AWS costs down.

## What it builds

- **Networking:** VPC with public and private subnets across two AZs, internet gateway and NAT gateway
- **EKS 1.37:** managed node group with a hardened launch template (IMDSv2, encrypted volumes), access entries for cluster admins, and core add-ons managed in Terraform
- **Pod Identity:** IAM roles for in-cluster services, scoped to a single Route 53 zone
- **Ingress:** NGINX Ingress Controller
- **TLS:** cert-manager (self-signed locally, Let's Encrypt on AWS)
- **DNS:** ExternalDNS managing Route 53 records for `moshire.co.uk`
- **State:** remote state in S3 with DynamoDB locking

## Repository layout

```
.
├── docker-compose.yml        # MiniStack (local AWS emulator)
└── terraform/
    ├── bootstrap/
    │   ├── local/            # state bucket, lock table, ECR in MiniStack
    │   └── aws/              # the same in the real AWS account
    ├── modules/
    │   ├── state-backend/    # S3 + DynamoDB for Terraform state
    │   ├── ecr/
    │   ├── vpc/
    │   ├── iam/              # cluster and node roles
    │   ├── eks/              # cluster, node group, launch template, add-ons, access
    │   └── pod-id-role/      # reusable Pod Identity role + association
    ├── infra/
    │   └── local/            # local environment: wires the modules together
    └── helm-values/          # shared values + per-environment overrides
```

Modules are written once and called from each environment. Helm values are layered: `<tool>.yaml` holds shared settings, and `<tool>-local.yaml` / `<tool>-aws.yaml` hold environment-specific overrides.

## Running locally

**Requirements:** Docker Desktop, Terraform >= 1.10, AWS CLI v2, kubectl, Helm.

Add a MiniStack profile so local commands never reach real AWS:

```ini
# ~/.aws/config
[profile ministack]
region = us-east-1
endpoint_url = http://localhost:4566
```

```ini
# ~/.aws/credentials
[ministack]
aws_access_key_id = test
aws_secret_access_key = test
```

Then bring everything up:

```bash
export AWS_PROFILE=ministack
docker compose up -d --wait

cd terraform/bootstrap/local && terraform init && terraform apply
cd ../../infra/local && terraform init && terraform apply

aws eks update-kubeconfig --name eks-platform-cluster
kubectl get pods -A
```

The local environment is disposable. Restarting Docker wipes MiniStack, including the state bucket, so run the steps above again after a restart.

## Design decisions

- **MiniStack for local development.** EKS on MiniStack runs a real k3s cluster, so Terraform, Helm and Kubernetes manifests can be tested without paying for EKS. Real AWS is used for short, deliberate test runs.
- **Pod Identity over IRSA.** No per-cluster OIDC provider, and the same trust policy for every role. Which service account gets which role lives in an explicit association.
- **Access entries over `aws-auth`.** Cluster access is managed through the EKS API, so it's visible in Terraform and can't be broken by a bad ConfigMap edit.
- **Ingress first, Gateway API next.** The platform starts on the Ingress API, with a planned migration to Gateway API.

## Local vs AWS differences

MiniStack is more forgiving than AWS. Things that work locally but are only truly tested on AWS:

- IAM policies are not enforced locally
- EKS add-ons are recorded but not run; k3s provides its own DNS, networking and kube-proxy
- Pod Identity does not work in k3s, so ExternalDNS uses static test credentials locally
- No load balancers locally; the ingress controller uses `NodePort` and is reached with `kubectl port-forward`
- Let's Encrypt cannot validate locally, so a self-signed issuer is used

Known MiniStack workarounds are commented in the code (for example, `upgrade_policy` is omitted locally because MiniStack has no `UpdateClusterConfig` API).

## Roadmap

- [x] Terraform: VPC, IAM, EKS, remote state
- [x] Pod Identity roles for cert-manager and ExternalDNS
- [x] NGINX Ingress, cert-manager and ExternalDNS installed
- [ ] Test app with HTTPS ingress and DNS record
- [ ] ArgoCD GitOps deployments
- [ ] CI/CD: Terraform pipeline, Checkov, Docker build, Trivy, deploy to EKS
- [ ] Prometheus and Grafana dashboards
- [ ] Architecture diagram
- [ ] Real AWS environment (`infra/aws`)
- [ ] Migrate Ingress to Gateway API