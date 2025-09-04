# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Generate random password for RDS (if enabled)
resource "random_password" "db_password" {
  count   = var.enable_rds ? 1 : 0
  length  = 32
  special = true
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.availability_zones)
  
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_flow_logs     = var.enable_flow_logs

  common_tags = var.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name   = var.project_name
  environment    = var.environment
  cluster_version = var.cluster_version
  
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # Node group configuration
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_disk_size      = var.node_disk_size

  common_tags = var.common_tags

  depends_on = [module.vpc]
}

# ALB Controller Module
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment
  
  cluster_name          = module.eks.cluster_name
  cluster_oidc_provider = module.eks.oidc_provider_arn
  vpc_id               = module.vpc.vpc_id

  common_tags = var.common_tags

  depends_on = [module.eks]
}

# RDS Module (conditional)
module "rds" {
  count  = var.enable_rds ? 1 : 0
  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment
  
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnets
  eks_security_group_id      = module.eks.node_security_group_id
  
  engine                     = var.db_engine
  engine_version             = var.db_engine_version
  instance_class             = var.db_instance_class
  allocated_storage          = var.db_allocated_storage
  max_allocated_storage      = var.db_max_allocated_storage
  storage_encrypted          = var.db_storage_encrypted
  multi_az                   = var.db_multi_az
  
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = random_password.db_password[0].result
  
  backup_retention_period    = var.db_backup_retention_period
  backup_window              = var.db_backup_window
  maintenance_window         = var.db_maintenance_window
  skip_final_snapshot        = var.db_skip_final_snapshot
  deletion_protection        = var.db_deletion_protection

  common_tags = var.common_tags

  depends_on = [module.vpc, module.eks]
}

# Redis Module (conditional)
module "redis" {
  count  = var.enable_redis ? 1 : 0
  source = "./modules/redis"

  project_name = var.project_name
  environment  = var.environment
  
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnets
  eks_security_group_id = module.eks.node_security_group_id
  
  node_type              = var.redis_node_type
  parameter_group_name   = var.redis_parameter_group_name
  engine_version         = var.redis_engine_version
  num_cache_clusters     = var.redis_num_cache_clusters
  port                   = var.redis_port
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled       = var.redis_multi_az_enabled

  common_tags = var.common_tags

  depends_on = [module.vpc, module.eks]
}

# MSK Module (conditional)
module "msk" {
  count  = var.enable_msk ? 1 : 0
  source = "./modules/msk"

  project_name = var.project_name
  environment  = var.environment
  
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnets
  eks_security_group_id = module.eks.node_security_group_id
  
  kafka_version           = var.msk_kafka_version
  instance_type           = var.msk_instance_type
  ebs_volume_size         = var.msk_ebs_volume_size
  number_of_broker_nodes  = var.msk_number_of_broker_nodes

  common_tags = var.common_tags

  depends_on = [module.vpc, module.eks]
}

# Bastion Host (conditional)
resource "aws_instance" "bastion" {
  count                  = var.enable_bastion ? 1 : 0
  ami                    = data.aws_ami.amazon_linux[0].id
  instance_type          = var.bastion_instance_type
  key_name               = var.bastion_key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion[0].id]

  user_data = base64encode(templatefile("${path.module}/user_data/bastion.sh", {
    cluster_name = module.eks.cluster_name
    region       = var.region
  }))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion"
    Type = "bastion"
  })
}

# Bastion Security Group
resource "aws_security_group" "bastion" {
  count       = var.enable_bastion ? 1 : 0
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # In production, restrict this to specific IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  })
}

# AMI data source for bastion
data "aws_ami" "amazon_linux" {
  count       = var.enable_bastion ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Store RDS password in AWS Secrets Manager (if RDS is enabled)
resource "aws_secretsmanager_secret" "db_password" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.project_name}-${var.environment}-db-password"
  description = "RDS database password for ${var.project_name} ${var.environment}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-password"
    Type = "database-credential"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  count         = var.enable_rds ? 1 : 0
  secret_id     = aws_secretsmanager_secret.db_password[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password[0].result
    endpoint = module.rds[0].db_instance_endpoint
    port     = module.rds[0].db_instance_port
    dbname   = var.db_name
  })
}
