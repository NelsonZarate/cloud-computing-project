terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    minikube = {
      source = "scott-the-programmer/minikube"
      version = "0.6.0"
    }
  }
}

provider "kubernetes" {
    host = minikube_cluster.Nike_cluster.host

    client_certificate     = minikube_cluster.Nike_cluster.client_certificate
    client_key             = minikube_cluster.Nike_cluster.client_key
    cluster_ca_certificate = minikube_cluster.Nike_cluster.cluster_ca_certificate

}

provider "minikube" {
  kubernetes_version = "v1.30.2"
}