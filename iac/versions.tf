terraform {
  required_version = ">= 1.9.4"

  required_providers {
    kubernetes = {
      source  = "registry.terraform.io/hashicorp/kubernetes"
      version = "2.31.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.14.1"
    }
  }
}