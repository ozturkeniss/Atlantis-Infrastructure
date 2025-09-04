# Production Environment Configuration
# ⚠️ These are example values for demonstration purposes only

# Project Configuration
project_name = "atlas-micro"
environment  = "prod"
region       = "eu-west-1"

# Network Configuration
vpc_cidr             = "10.2.0.0/16"
availability_zones   = 3  # Use 3 AZs for production
enable_nat_gateway   = true
single_nat_gateway   = false  # Multiple NAT gateways for HA
enable_dns_hostnames = true
enable_dns_support   = true

# EKS Configuration
cluster_version                = "1.28"
cluster_endpoint_public_access = false  # More secure for production
cluster_endpoint_private_access = true

# Node Group Configuration
node_instance_types = ["m5.large", "m5.xlarge"]
node_desired_size   = 6
node_min_size       = 3
node_max_size       = 12
node_disk_size      = 100

# Feature Toggles - Production has all features enabled
enable_rds         = true
enable_redis       = true
enable_msk         = true
enable_bastion     = true

# RDS Configuration (when enabled)
db_engine          = "postgres"
db_engine_version  = "15.4"
db_instance_class  = "db.r6g.large"
db_allocated_storage = 500
db_max_allocated_storage = 1000  # Auto-scaling storage
db_storage_encrypted = true
db_multi_az         = true  # Multi-AZ for production
db_name            = "atlasdb"
db_username        = "atlas_user"
db_backup_retention_period = 30  # Longer retention for production
db_backup_window          = "03:00-04:00"
db_maintenance_window     = "sun:04:00-sun:05:00"
db_skip_final_snapshot    = false
db_deletion_protection    = true

# Redis Configuration (when enabled)
redis_node_type              = "cache.r6g.large"
redis_parameter_group_name   = "default.redis7"
redis_engine_version         = "7.0"
redis_num_cache_clusters     = 3  # Multi-AZ Redis
redis_port                   = 6379
redis_automatic_failover_enabled = true
redis_multi_az_enabled       = true

# MSK Configuration (when enabled)
msk_kafka_version    = "3.5.1"
msk_instance_type    = "kafka.m5.large"
msk_ebs_volume_size  = 1000
msk_number_of_broker_nodes = 3

# Bastion Configuration (when enabled)
bastion_instance_type = "t3.small"
bastion_key_name      = "atlas-prod-key"

# Security Configuration
enable_flow_logs = true
enable_guardduty = true
enable_config    = true

# Monitoring Configuration
enable_cloudwatch_logs = true
log_retention_days     = 30

# Tags
common_tags = {
  Project     = "atlas-micro"
  Environment = "prod"
  ManagedBy   = "terraform"
  Owner       = "platform-team"
  CostCenter  = "engineering"
  Backup      = "required"
  Compliance  = "gdpr"
}
