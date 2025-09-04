provider "aws" {
  region = var.region

  # Default tags applied to all resources
  default_tags {
    tags = var.common_tags
  }
}

# Kubernetes provider configuration
# Note: This provider configuration assumes EKS cluster exists
# In practice, you might need to configure this after EKS creation
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally.
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Helm provider configuration
# Note: This provider configuration assumes EKS cluster exists
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# Local provider for data processing
provider "random" {}
provider "tls" {}
