terraform {
  required_version = ">= 1.0"

  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "minikube" {
  # Opcional: pode-se especificar a versão do Kubernetes aqui, ex: kubernetes_version = "v1.30.0"
  kubernetes_version = "v1.37.0"
}