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
    time = {
      source = "hashicorp/time"
      version = "0.9.1"
    }
  }
}
