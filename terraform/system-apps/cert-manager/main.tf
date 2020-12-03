

resource "helm_release" "cert-manager-crds" {
  name  = "tf-cert-manager-crds"
  chart = "cert-manager-crds"
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  name  = "tf-cert-manager"
  chart = "cert-manager"
  version    = "1.0.1"
  repository = data.helm_repository.jetstack.metadata[0].name
  depends_on = [helm_release.cert-manager-crds]
}


resource "helm_release" "cert-manager-issuer" {
  name  = "tf-cert-manager-issuer"
  chart = "cert-manager-issuer"
  depends_on = [helm_release.cert-manager]

  set_string {
    name = "acme_email"
    value = var.acme_email
  }
}
