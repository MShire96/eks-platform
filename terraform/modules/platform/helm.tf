locals {
  values_dir = "${path.module}/../../helm-values"

  # Base file + chart-env.yaml for each chart
  helm_values = {
    for chart in ["nginx-ingress", "cert-manager", "external-dns", "argocd"] :
    chart => [
      for f in ["${chart}.yaml", "${chart}-${var.environment}.yaml"] :
      file("${local.values_dir}/${f}") if fileexists("${local.values_dir}/${f}")
    ]
  }
}

resource "helm_release" "nginx" {
  name = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart = "nginx-ingress"
  version = "2.8.1"
  namespace = "nginx-ingress"
  create_namespace = true
  values = local.helm_values["nginx-ingress"]
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "1.21.3"
  namespace = "cert-manager"
  create_namespace = true
  values = local.helm_values["cert-manager"]
  depends_on = [module.cert_manager_pod_identity]
}

resource "helm_release" "external_dns" {
  name = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart = "external-dns"
  version = "1.23.0"
  namespace = "external-dns"
  create_namespace = true
  values           = local.helm_values["external-dns"]
  depends_on = [module.external_dns_pod_identity]
}

resource "helm_release" "argo_cd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "10.18.0"
  namespace = "argocd"
  create_namespace = true
  values           = local.helm_values["argocd"]
  depends_on = [helm_release.nginx, helm_release.cert_manager]
}