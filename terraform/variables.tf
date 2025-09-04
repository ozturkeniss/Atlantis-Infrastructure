# Core Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "atlas-micro"
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
  
  validation {
    condition     = var.availability_zones >= 2 && var.availability_zones <= 3
    error_message = "Number of availability zones must be between 2 and 3."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

# EKS Configuration
variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to EKS cluster endpoint"
  type        = bool
  default     = true
}

# Node Group Configuration
variable "node_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Disk size for EKS node group instances"
  type        = number
  default     = 50
}

# Feature Toggles
variable "enable_rds" {
  description = "Enable RDS PostgreSQL database"
  type        = bool
  default     = false
}

variable "enable_redis" {
  description = "Enable ElastiCache Redis cluster"
  type        = bool
  default     = false
}

variable "enable_msk" {
  description = "Enable Amazon MSK Kafka cluster"
  type        = bool
  default     = false
}

variable "enable_bastion" {
  description = "Enable bastion host for cluster access"
  type        = bool
  default     = false
}

# RDS Configuration
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for RDS instance (GB)"
  type        = number
  default     = null
}

variable "db_storage_encrypted" {
  description = "Enable storage encryption for RDS instance"
  type        = bool
  default     = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for RDS instance"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "atlasdb"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "atlas_user"
}

variable "db_backup_retention_period" {
  description = "Backup retention period for RDS instance (days)"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Backup window for RDS instance"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Maintenance window for RDS instance"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS instance"
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for RDS instance"
  type        = bool
  default     = false
}

# Redis Configuration
variable "redis_node_type" {
  description = "Node type for ElastiCache Redis cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_parameter_group_name" {
  description = "Parameter group name for ElastiCache Redis cluster"
  type        = string
  default     = "default.redis7"
}

variable "redis_engine_version" {
  description = "Engine version for ElastiCache Redis cluster"
  type        = string
  default     = "7.0"
}

variable "redis_num_cache_clusters" {
  description = "Number of cache clusters for ElastiCache Redis"
  type        = number
  default     = 1
}

variable "redis_port" {
  description = "Port for ElastiCache Redis cluster"
  type        = number
  default     = 6379
}

variable "redis_automatic_failover_enabled" {
  description = "Enable automatic failover for ElastiCache Redis cluster"
  type        = bool
  default     = false
}

variable "redis_multi_az_enabled" {
  description = "Enable Multi-AZ for ElastiCache Redis cluster"
  type        = bool
  default     = false
}

# MSK Configuration
variable "msk_kafka_version" {
  description = "Kafka version for MSK cluster"
  type        = string
  default     = "3.5.1"
}

variable "msk_instance_type" {
  description = "Instance type for MSK cluster"
  type        = string
  default     = "kafka.t3.small"
}

variable "msk_ebs_volume_size" {
  description = "EBS volume size for MSK cluster (GB)"
  type        = number
  default     = 100
}

variable "msk_number_of_broker_nodes" {
  description = "Number of broker nodes for MSK cluster"
  type        = number
  default     = 2
}

# Bastion Configuration
variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "Key pair name for bastion host"
  type        = string
  default     = null
}

# Security Configuration
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = false
}

variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention period (days)"
  type        = number
  default     = 7
}
