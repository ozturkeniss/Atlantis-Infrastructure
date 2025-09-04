# EKS Module using terraform-aws-modules/eks/aws
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  
  # Cluster endpoint access CIDR blocks - restrict in production
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = var.node_instance_types
    
    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    main = {
      name = "${var.project_name}-${var.environment}-main"
      
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"
      
      # Node group disk configuration
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.node_disk_size
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      # Remote access configuration (optional SSH access)
      remote_access = {
        ec2_ssh_key               = var.ssh_key_name
        source_security_group_ids = var.additional_security_group_ids
      }

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      taints = []

      tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-main-nodes"
      })
    }
  }

  # aws-auth configmap
  # we need to map additional IAM users/roles for EKS access
  manage_aws_auth_configmap = true
  
  aws_auth_users = var.aws_auth_users
  aws_auth_accounts = var.aws_auth_accounts

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks"
  })
}

# Note: Karpenter configuration would be added here for advanced auto-scaling
# For this demo, we're using standard EKS managed node groups
# In production, consider adding Karpenter for more flexible node provisioning
