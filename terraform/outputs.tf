# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

# EKS Outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = module.eks.eks_managed_node_groups["main"].node_group_arn
}

# RDS Outputs (conditional)
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.enable_rds ? module.rds[0].db_instance_endpoint : null
}

output "rds_port" {
  description = "RDS instance port"
  value       = var.enable_rds ? module.rds[0].db_instance_port : null
}

output "rds_database_name" {
  description = "RDS database name"
  value       = var.enable_rds ? module.rds[0].db_instance_name : null
}

# Redis Outputs (conditional)
output "redis_endpoint" {
  description = "ElastiCache Redis cluster endpoint"
  value       = var.enable_redis ? module.redis[0].redis_primary_endpoint : null
}

output "redis_port" {
  description = "ElastiCache Redis cluster port"
  value       = var.enable_redis ? module.redis[0].redis_port : null
}

# MSK Outputs (conditional)
output "msk_bootstrap_brokers" {
  description = "MSK cluster bootstrap brokers"
  value       = var.enable_msk ? module.msk[0].bootstrap_brokers : null
}

output "msk_bootstrap_brokers_tls" {
  description = "MSK cluster bootstrap brokers (TLS)"
  value       = var.enable_msk ? module.msk[0].bootstrap_brokers_tls : null
}

output "msk_cluster_arn" {
  description = "MSK cluster ARN"
  value       = var.enable_msk ? module.msk[0].cluster_arn : null
}

# ALB Outputs
output "alb_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.alb.alb_controller_role_arn
}

# Bastion Outputs (conditional)
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].private_ip : null
}

# Useful Commands Output
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "useful_commands" {
  description = "Useful commands for cluster management"
  value = {
    kubectl_config = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
    bastion_ssh    = var.enable_bastion ? "ssh -i ~/.ssh/${var.bastion_key_name}.pem ec2-user@${aws_instance.bastion[0].public_ip}" : "Bastion not enabled"
    helm_repos = {
      aws_load_balancer_controller = "helm repo add eks https://aws.github.io/eks-charts"
      external_dns                 = "helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/"
      prometheus                   = "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
      grafana                      = "helm repo add grafana https://grafana.github.io/helm-charts"
      argocd                       = "helm repo add argo https://argoproj.github.io/argo-helm"
    }
  }
}
