# IRSA (IAM Roles for Service Accounts) configurations
# These roles allow Kubernetes service accounts to assume AWS IAM roles

# AWS Load Balancer Controller IRSA
module "aws_load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.project_name}-${var.environment}-aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-aws-load-balancer-controller"
  })
}

# External DNS IRSA
module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                     = "${var.project_name}-${var.environment}-external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/*"]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-external-dns"
  })
}

# Cluster Autoscaler IRSA
module "cluster_autoscaler_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                        = "${var.project_name}-${var.environment}-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cluster-autoscaler"
  })
}

# EBS CSI Driver IRSA
module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.project_name}-${var.environment}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ebs-csi"
  })
}

# AWS VPC CNI IRSA (for advanced VPC CNI configurations)
module "vpc_cni_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.project_name}-${var.environment}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc-cni"
  })
}

# AWS for Fluent Bit IRSA (for CloudWatch logging)
module "aws_for_fluent_bit_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                          = "${var.project_name}-${var.environment}-fluent-bit"
  attach_aws_for_fluent_bit_policy   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "amazon-cloudwatch:fluent-bit",
        "kube-system:fluent-bit"
      ]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-fluent-bit"
  })
}

# Application specific IRSA roles can be added here
# Example: For applications that need to access S3, SQS, etc.

# Generic application IRSA role template
# Uncomment and modify as needed for your applications
/*
module "app_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.project_name}-${var.environment}-app-role"
  
  role_policy_arns = {
    s3_policy = aws_iam_policy.app_s3_policy.arn
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "services:api-01",
        "services:api-02"
      ]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-app-role"
  })
}

resource "aws_iam_policy" "app_s3_policy" {
  name        = "${var.project_name}-${var.environment}-app-s3-policy"
  description = "Policy for applications to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.environment}-bucket/*"
        ]
      }
    ]
  })

  tags = var.common_tags
}
*/
