output "alb_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.aws_load_balancer_controller_irsa_role.iam_role_arn
}

output "alb_controller_role_name" {
  description = "Name of the AWS Load Balancer Controller IAM role"
  value       = module.aws_load_balancer_controller_irsa_role.iam_role_name
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.alb.arn
}

output "sample_alb_annotations" {
  description = "Sample ALB annotations for ingress resources"
  value       = local.sample_alb_annotations
}

output "helm_install_command" {
  description = "Helm command to install AWS Load Balancer Controller"
  value = <<-EOT
    # Add the EKS chart repository
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    # Install AWS Load Balancer Controller
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      --set clusterName=${var.cluster_name} \
      --set serviceAccount.create=false \
      --set serviceAccount.name=aws-load-balancer-controller \
      --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${module.aws_load_balancer_controller_irsa_role.iam_role_arn} \
      -n kube-system
  EOT
}
