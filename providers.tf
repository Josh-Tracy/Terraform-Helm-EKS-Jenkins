terraform {
  required_providers {
    aws = {
        version = "4.21.0"
    }
    helm = {
        version = "2.6.0"
    }
    kubernetes = {
        version = "2.12.1"
    }
  }
  required_version = "~> 1.2.6"
}

provider "helm" {
    kubernetes {
        host                   = data.aws_eks_cluster.dev-cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev-cluster.certificate_authority.0.data)
            exec {
                api_version = "client.authentication.k8s.io/v1beta1"
                args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.dev-cluster.name]
                command     = "aws"
            }
    }
}


provider "kubernetes" {
    host                   = data.aws_eks_cluster.dev-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.dev-cluster.token
    #load_config_file       = false
}

provider "aws" {
    region = var.aws_region
}