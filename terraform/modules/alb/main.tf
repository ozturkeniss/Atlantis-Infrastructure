# AWS Load Balancer Controller IAM Role
# This module creates the necessary IAM role for the AWS Load Balancer Controller

# IAM Role for AWS Load Balancer Controller
module "aws_load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.project_name}-${var.environment}-aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-aws-load-balancer-controller"
    Component   = "load-balancer-controller"
    Description = "IAM role for AWS Load Balancer Controller"
  })
}

# Additional IAM policy for ALB ingress (if needed)
resource "aws_iam_policy" "alb_ingress_additional" {
  name        = "${var.project_name}-${var.environment}-alb-ingress-additional"
  description = "Additional policy for ALB Ingress Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInternetGateways",
          "elasticloadbalancing:SetWebAcl",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:DescribeProtection",
          "shield:GetSubscriptionState",
          "shield:DescribeSubscription",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-ingress-additional"
  })
}

# Attach additional policy to the role
resource "aws_iam_role_policy_attachment" "alb_ingress_additional" {
  policy_arn = aws_iam_policy.alb_ingress_additional.arn
  role       = module.aws_load_balancer_controller_irsa_role.iam_role_name
}

# Output the role ARN for use in Helm chart annotations
# The role ARN will be used in the Helm chart deployment like this:
# 
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
#   --set clusterName=${cluster_name} \
#   --set serviceAccount.create=false \
#   --set serviceAccount.name=aws-load-balancer-controller \
#   --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${role_arn} \
#   -n kube-system

# Sample Ingress annotations for ALB
locals {
  sample_alb_annotations = {
    # Basic ALB configuration
    "kubernetes.io/ingress.class"                    = "alb"
    "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"          = "ip"
    
    # Health check configuration
    "alb.ingress.kubernetes.io/healthcheck-path"     = "/health"
    "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "15"
    "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "5"
    "alb.ingress.kubernetes.io/healthy-threshold-count"      = "2"
    "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = "2"
    
    # SSL configuration
    "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
    "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
    "alb.ingress.kubernetes.io/certificate-arn"      = "arn:aws:acm:region:account:certificate/cert-id"
    
    # Security
    "alb.ingress.kubernetes.io/security-groups"      = "${var.project_name}-${var.environment}-alb-sg"
    "alb.ingress.kubernetes.io/wafv2-acl-arn"       = "arn:aws:wafv2:region:account:regional/webacl/name/id"
    
    # Tagging
    "alb.ingress.kubernetes.io/tags"                = "Environment=${var.environment},Project=${var.project_name}"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for ALB"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
